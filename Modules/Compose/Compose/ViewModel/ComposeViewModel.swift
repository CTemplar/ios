import Foundation
import Combine
import Utility
import Networking
import InboxViewer
import CoreGraphics
import PGPFramework


final class ComposeViewModel: Modelable {
    // MARK: Properties
    let pgpService = UtilityManager.shared.pgpService
    
    let formatterService = UtilityManager.shared.formatterService
    
    @Published private (set) var answerMode: AnswerMessageMode
    
    @Published private (set) var shouldEnableSendButton: Bool = false
    
    private (set) var reloadSections = PassthroughSubject<IndexSet, Never>()
    
    private (set) var reloadWholeList = PassthroughSubject<Void, Never>()
    
    private (set) var showBanner = PassthroughSubject<String, Never>()
    
    private var sendButtonState = PassthroughSubject<Void, Never>()
    
    private (set) var showAlert = PassthroughSubject<(AlertKitParams, Bool), Never>()
    
    private (set) var user: UserMyself
    
    private (set) var email: EmailMessage
    
    private (set) var includeAttachments: Bool
    
    private let sections = ComposeSection.allCases
    
    private var collapsed = true
    
    private (set) var fromCellVM: ComposeMailFromEmailModel?
    
    private (set) var toCellVM: ComposeMailOtherEmailModel?
    
    private (set) var ccCellVM: ComposeMailOtherEmailModel?
    
    private (set) var bccCellVM: ComposeMailOtherEmailModel?
    
    private (set) var subjectCellVM: ComposeMailSubjectModel?
    
    private (set) var menuCellVM: ComposeMailMenuModel?
    
    private (set) var attachmentCellVM: MailAttachmentCellModel?
    
    private (set) var contentCellVM: ComposeMailSubjectModel?
    
    private var bindables = Set<AnyCancellable>()
    
    let fetcher = ComposeFetcher()
    
    private (set) var mailboxId = 0
    
    private (set) var currentSignature: String?
    
    private (set) var emailPassword = ""
    
    private var contacts: [Contact] = []
    
    private (set) var parentMail: EmailMessage?
    
    private var isContactEncrypted: Bool {
        return user.settings.isContactsEncrypted ?? false
    }
    
    var mailboxList: [Mailbox] {
        return user.mailboxesList ?? []
    }
    
    var defaultMailbox: Mailbox? {
        return user.mailboxesList?.first(where: { $0.isDefault == true })
    }
    
    // MARK: - Constructor
    init(answerMode: AnswerMessageMode, user: UserMyself) {
        self.answerMode = answerMode
        self.user = user
        self.email = EmailMessage()
        self.email.update(messsageID: 0)
        
        switch answerMode {
        case .newMessageWithReceiverEmail(let emailId):
            self.email.update(receivers: [emailId])
        default: break
        }
        
        self.includeAttachments = true
        
        sendButtonState
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .sink { [weak self] (_) in
                self?.shouldEnableSendButton.toggle()
                self?.updateSendButtonState()
        }.store(in: &bindables)
    }
    
    init(answerMode: AnswerMessageMode, user: UserMyself, message: EmailMessage, includeAttachments: Bool) {
        self.answerMode = answerMode
        self.user = user
        self.parentMail = message
        self.email = message
        self.includeAttachments = includeAttachments
        
        sendButtonState
            .debounce(for: 2.0, scheduler: DispatchQueue.main)
            .sink { [weak self] (_) in
                self?.updateSendButtonState()
        }.store(in: &bindables)
    }
    
    deinit {
        DPrint("ComposeViewModel deinitialized")
    }
    
    // MARK: - Setup Datasource
    func setupDatasource() {
        switch answerMode {
        case .reply:
            if let lastChild = email.children?.last {
                email.update(receivers: [lastChild.sender ?? ""])
            } else {
                email.update(receivers: [email.sender ?? ""])
            }
        case .replyAll:
            var receivers: [String] = []
            if let lastChild = email.children?.last {
                receivers = lastChild.receivers ?? []
            } else {
                receivers = email.receivers ?? []
            }
            email.update(receivers: receivers)
        default: break
        }
        
        setupMailboxWithSignature()
        
        let list = receiversList()
        // When user tapped on compose mail
        if email.messsageID == 0 {
            let messageContent = encryptMessageWithOwnPublicKey(message: "")
            Loader.start()
            
            fetcher
                .createDraftMessage(parentID: "",
                                    content: messageContent,
                                    subject: email.subject ?? "",
                                    recievers: list,
                                    folder: MessagesFoldersName.draft.rawValue,
                                    mailboxID: mailboxId,
                                    send: false,
                                    encrypted: false,
                                    encryptionObject: [:],
                                    attachments: self.includeAttachments ? email.attachments?.map({ $0.toDictionary() }) ?? [] : [],
                                    isSubjectEncrypted: user.settings.isSubjectEncrypted ?? false,
                                    sender: email.sender ?? "",
                                    lastAction: answerMode.localized,
                                    onCompletion:
                { [weak self] (message) in
                    if let email = message {
                        self?.email = email
                        // Fetch Contacts
                        DispatchQueue.main.async {
                            self?.setupCellVMs()
                        }
                        
                        DispatchQueue.global(qos: .background).async {
                            self?.fetcher.fetchContactsForComposeMail({ (contacts) in
                                    DispatchQueue.main.async {
                                       // self?.contacts = contacts
                                        self?.updateContacts(contacts: contacts)
                                    }
                            })
                        }
                    }
            }) { [weak self] (params, backToRoot) in
                Loader.stop()
                self?.showAlert.send((params, backToRoot))
            }
        } else {
            Loader.start()
            
            if email.folder == MessagesFoldersName.draft.rawValue {
                DispatchQueue.main.async {
                    self.setupCellVMs()
                }
                DispatchQueue.global(qos: .background).async {
                    self.fetcher.fetchContactsForComposeMail({ [weak self] (contacts) in
                        DispatchQueue.main.async {
                            self?.updateContacts(contacts: contacts)
                        }
                    })
                }
            } else {
                var messageContent = getMailContent(from: email)
                
                if messageContent.contains("BEGIN PGP"), let decryptedContent = decryptedMailContent(from: email) {
                    messageContent = decryptedContent
                }
                
                var encryptionObjectDictionary = [String: String]()
                
                if let encryptionObject = email.encryption {
                    encryptionObjectDictionary = encryptionObject.toDictionary()
                }
                
                fetcher
                    .createDraftMessage(parentID: email.messsageID?.description ?? "",
                                        content: messageContent,
                                        subject: email.subject ?? "",
                                        recievers: list,
                                        folder: MessagesFoldersName.draft.rawValue,
                                        mailboxID: mailboxId,
                                        send: false,
                                        encrypted: email.isEncrypted ?? true,
                                        encryptionObject: encryptionObjectDictionary,
                                        attachments: self.includeAttachments ? email.attachments?.map({ $0.toDictionary() }) ?? [] : [],
                                        isSubjectEncrypted: user.settings.isSubjectEncrypted ?? false,
                                        sender: email.sender ?? "",
                                        lastAction: answerMode.localized)
                    { [weak self] (message) in
                        if let message  = message {
                            self?.email = message
                            DispatchQueue.main.async {
                                self?.setupCellVMs()
                            }
                            DispatchQueue.global(qos: .background).async {

                                // Fetch Contacts
                                self?.fetcher.fetchContactsForComposeMail({ (contacts) in
                                    DispatchQueue.main.async {
                                        //self?.contacts = contacts
                                        self?.updateContacts(contacts: contacts)
                                    }
                                })
                            }
                        }
                } onCompletionWithAlert: { [weak self] (params, backToRoot) in
                    Loader.stop()
                    self?.showAlert.send((params, backToRoot))
                }
            }
        }
        
        
    }
    
    
    private func updateContacts(contacts:[Contact]) {
        for contactsResult in contacts {
            if contactsResult.isEncrypted ?? false {
                if let unwrappedData = contactsResult.encryptedData {
                    DispatchQueue.global(qos: .utility).async {
                        self.decryptContactData(encryptedData: unwrappedData, contact: contactsResult)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.contacts.append(contactsResult)
                    self.toCellVM?.updateContacts(contacts: self.contacts)
                    self.ccCellVM?.updateContacts(contacts: self.contacts)
                    self.bccCellVM?.updateContacts(contacts: self.contacts)
                }
            }
        }
    }
    
    func decryptContactData(encryptedData: String, contact: Contact)  {
        guard let decryptedContent = self.decrypt(content: encryptedData) else {
            DPrint("Nothing")
            return
        }
        let dictionary = self.convertStringToDictionary(text: decryptedContent)
        let encryptedContact = Contact(encryptedDictionary: dictionary, contactId: contact.contactID ?? 0, encryptedData: contact.encryptedData ?? "")
        DispatchQueue.main.async {
            self.contacts.append(encryptedContact)
            self.toCellVM?.updateContacts(contacts: self.contacts)
            self.ccCellVM?.updateContacts(contacts: self.contacts)
            self.bccCellVM?.updateContacts(contacts: self.contacts)
        }
    }
    
    // MARK: - decrypt Contact
     func decrypt(content: String) -> String? {
        let password = UtilityManager.shared.keychainService.getPassword()
        if let contentData = content.data(using: .ascii) {
            if let data =  PGPEncryption().decryptSimpleMessage(encrypted: contentData, userPassword: password) {
                return  String(decoding: data, as: UTF8.self)
            }
        }
        else {
            return nil
        }
        return nil
    }
    
    
    private func convertStringToDictionary(text: String) -> [String:Any] {
        var dicitionary = [String: Any]()
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    dicitionary = json
                }
                return dicitionary
                
            } catch {
                DPrint("convertStringToDictionary: Something went wrong string ->", text)
                return dicitionary
            }
        }
        return dicitionary
    }

    
    private func setupMailboxWithSignature() {
        currentSignature = UserDefaults.standard.string(forKey: mobileSignatureKey) ?? ""
        
        if let defaultMailbox = self.defaultMailbox {
            if let defaultEmail = defaultMailbox.email {
                email.update(sender: defaultEmail)
            }
            
            if let signature = currentSignature, signature.isEmpty {
                currentSignature = defaultMailbox.signature ?? ""
            }
            mailboxId = defaultMailbox.mailboxID ?? 0
        }
    }
    
    private func setupCellVMs() {
        // From Prefix
        var sender = email.sender ?? ""
        
        if sender.isEmpty {
            sender = defaultMailbox?.email ?? ""
        }
        
        fromCellVM = ComposeMailFromEmailModel(mailId: sender)
        
        fromCellVM?
            .$mailId
            .receive(on: RunLoop.main)
            .sink { [weak self] (emailId) in
                self?.email.update(sender: emailId)
        }
        .store(in: &bindables)
        
        // To Prefix
        let receiversList: [String] = answerMode == AnswerMessageMode.forward ? [] : email.receivers ?? []
        toCellVM = ComposeMailOtherEmailModel(mode: .to,
                                              contacts: contacts,
                                              mailIds: receiversList,
                                              isContactsEncrypted: isContactEncrypted,
                                              indexPath: IndexPath(row: 0, section: 0))
        toCellVM?
            .$mailIds
            .receive(on: RunLoop.main)
            .sink{ [weak self] (emailIds) in
                self?.email.update(receivers: emailIds)
                self?.sendButtonState.send()
        }
        .store(in: &bindables)
        
        // CC Prefix
        ccCellVM = ComposeMailOtherEmailModel(mode: .cc,
                                              contacts: contacts,
                                              mailIds: email.cc ?? [],
                                              isContactsEncrypted: isContactEncrypted,
                                              indexPath: IndexPath(row: 1, section: 0))
        ccCellVM?
            .$mailIds
            .receive(on: RunLoop.main)
            .sink{ [weak self] (emailIds) in
                self?.email.update(cc: emailIds)
        }
        .store(in: &bindables)
        
        // BCC Prefix
        bccCellVM = ComposeMailOtherEmailModel(mode: .bcc,
                                               contacts: contacts,
                                               mailIds: email.bcc ?? [],
                                               isContactsEncrypted: isContactEncrypted,
                                               indexPath: IndexPath(row: 2, section: 0))
        bccCellVM?
            .$mailIds
            .receive(on: RunLoop.main)
            .sink { [weak self] (emailIds) in
                self?.email.update(bcc: emailIds)
        }
        .store(in: &bindables)
        
        // Subject
        var subject = email.subject ?? ""
        
        if subject.contains("BEGIN PGP") == true, let decryptedSubject = decryptedMailContent(from: subject) {
            subject = decryptedSubject
        }
        
        subjectCellVM = ComposeMailSubjectModel(content: subject,
                                                contentType: .normalText)
        
        subjectCellVM?
            .subject
            .sink { [weak self] (subject) in
                self?.email.update(subject: subject)
                self?.sendButtonState.send()
                
        }
        .store(in: &bindables)
        
        // Menu
        var selectedMenus: [ComposeMailMenu] = []
        
        if includeAttachments, email.attachments?.isEmpty == false {
            selectedMenus.append(.attachment)
        }
        
        if email.deadManDuration != nil {
            selectedMenus.append(.deadManTimer)
        }
        
        if email.delayedDelivery?.isEmpty == false {
            selectedMenus.append(.delayedDelivery)
        }
        
        if email.encryption != nil {
            selectedMenus.append(.mailEncryption)
        }
        
        if email.destructDay?.isEmpty == false  {
            selectedMenus.append(.selfDesctructionTimer)
        }
        
        menuCellVM = ComposeMailMenuModel(selectedMenus: selectedMenus)
        
        // Attachments
        var attachmentModels: [MailAttachment] = []
        
        if includeAttachments,
            let attachments = email.attachments,
            !attachments.isEmpty {
            attachments.forEach({ [weak self] in
                if let attachmentModel = self?.getMailAttachment(from: $0) {
                    attachmentModels.append(attachmentModel)
                }
            })
        }
        
        attachmentCellVM = MailAttachmentCellModel(attachments: attachmentModels, spacing: 10.0)
        
        // Body
        let content = initialiseEmailContent()
        
        contentCellVM = ComposeMailSubjectModel(content: content,
                                                contentType: user.settings.isHtmlDisabled == false ? .htmlText : .normalText)
        
        contentCellVM?
            .subject
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] (content) in
                self?.email.update(content: content)
                self?.contentCellVM?.content = content
                self?.sendButtonState.send()
                
        }
        .store(in: &bindables)
        
        contentCellVM?
            .contentTypeSubject
            .sink { [weak self] (contentType) in
                self?.email.update(isHtml: contentType == .htmlText)
                
        }
        .store(in: &bindables)

        reloadWholeList.send()
        
        Loader.stop()
    }
    
    func getMailAttachment(from attachment: Attachment) -> MailAttachment? {
        if let url = attachment.contentUrl,
            let fileName = FileManager.fileName(fileUrl: url),
            let fileExtension = FileManager.fileExtension(fileUrl: url)
            {
            if let localUrl = attachment.localUrl, let fileExtension = FileManager.fileExtension(fileUrl: localUrl), let extensionType = GeneralConstant.DocumentsExtension(rawValue: fileExtension.lowercased()) {
                let attachment = MailAttachment(attachmentTitle: fileName,
                                                attachmentType: extensionType,
                                                contentURL: url,
                                                encrypted: attachment.encrypted ?? false,
                                                shoulDisplayRemove: true)
                return attachment
            }
            
        }
        return nil
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfRows(for section: Int) -> Int {
        guard sections.count > section else {
            return 0
        }
        let section = sections[section]
        return section.rows(isCollapsed: collapsed,
                            attachmentCount: email.attachments?.count ?? 0,
                            includeAttachments: includeAttachments).count
    }
    
    func rowDetails(at indexPath: IndexPath) -> ComposeRow? {
        guard sections.count > indexPath.section else {
            return nil
        }
        
        let section = sections[indexPath.section]
        
        let rows = section.rows(isCollapsed: collapsed,
                                attachmentCount: email.attachments?.count ?? 0,
                                includeAttachments: includeAttachments)
        
        guard rows.count > indexPath.row else {
            return nil
        }
        
        let row = rows[indexPath.row]
        
        return row
    }
    
    func rowHeight(at indexPath: IndexPath) -> CGFloat? {
        guard sections.count > indexPath.section else {
            return nil
        }
        
        let section = sections[indexPath.section]
        
        let rows = section.rows(isCollapsed: collapsed,
                                attachmentCount: email.attachments?.count ?? 0,
                                includeAttachments: includeAttachments)
        
        guard rows.count > indexPath.row else {
            return nil
        }
        
        let row = rows[indexPath.row]
        
        switch row {
        case .from, .subject, .menu:
            return 50.0
        case .to:
            return toCellVM?.height
        case .cc:
            return ccCellVM?.height
        case .bcc:
            return bccCellVM?.height
        case .attachment:
            return attachmentCellVM?.rowHeight
        case .body:
            return contentCellVM?.cellHeight ?? 0.0 > 200.0 ? nil : contentCellVM?.cellHeight
        }
    }
    
    func cellViewModel(at indexPath: IndexPath) -> Modelable? {
        guard sections.count > indexPath.section else {
            return nil
        }
        
        let section = sections[indexPath.section]
        
        let rows = section.rows(isCollapsed: collapsed,
                                attachmentCount: email.attachments?.count ?? 0,
                                includeAttachments: includeAttachments)
        
        guard rows.count > indexPath.row else {
            return nil
        }
        
        let row = rows[indexPath.row]
        
        switch row {
        case .from:
            return fromCellVM
        case .to:
            return toCellVM
        case .cc:
            return ccCellVM
        case .bcc:
            return bccCellVM
        case .subject:
            return subjectCellVM
        case .menu:
            return menuCellVM
        case .attachment:
            return attachmentCellVM
        case .body:
            return contentCellVM
        }
    }
    
    func getAttachments() -> [Attachment] {
        return email.attachments ?? []
    }
    
    func receiversList() -> [[String]] {
        var recieversList = [[String]]()
        recieversList.append(email.receivers ?? [])
        recieversList.append(email.cc ?? [])
        recieversList.append(email.bcc ?? [])
        return recieversList
    }
    
    func modifyScheduledDates(from date: Date?,
                              withMode mode: SchedulerMode) {
        switch mode {
        case .selfDestructTimer:
            guard let dateObj = date else {
                email.update(destructDay: nil)
                return
            }
            let scheduledDateString = formatterService.formatSelfShedulerDateToSringForAPIRequirements(date: dateObj)
            email.update(destructDay: scheduledDateString)
        case .deadManTimer:
            guard let dateObj = date else {
                email.update(deadManDuration: nil)
                return
            }
            let minutesCount = dateObj.minutesCountFromNow()
            let hoursCount = lroundf(Float(minutesCount)/60.0)
            email.update(deadManDuration: hoursCount)
        case .delayedDelivery:
            guard let dateObj = date else {
                email.update(delayedDelivery: nil)
                return
            }
            let scheduledDateString = formatterService.formatSelfShedulerDateToSringForAPIRequirements(date: dateObj)
            email.update(delayedDelivery: scheduledDateString)
        }
    }
    
    func decryptAttachment(data: Data) -> URL? {
        let decryptedAttachment = pgpService.decrypt(encryptedData: data)
        
        DPrint("decryptedAttachment:", decryptedAttachment as Any)
        
        guard let attachment = decryptedAttachment else {
            return nil
        }
        
        let tempFileUrl = GeneralConstant
            .getApplicationSupportDirectoryDirectory()
            .appendingPathComponent(InboxViewerConstant.attachmentFileName)
        
        do {
            try attachment.write(to: tempFileUrl)
        }  catch {
            DPrint("save decryptedAttachment Error")
        }
        
        return tempFileUrl
    }
    
    func shouldSaveDraft() -> Bool {
        if email.receivers?.isEmpty == true {
            return false
        }
        
        // Activating Send button without subject.
//        if email.subject?.isEmpty == true {
//            return false
//        }

        var messageContent = getMailContent(from: email)
        
        if messageContent.contains("BEGIN PGP"), let decryptedContent = decryptedMailContent(from: email) {
            messageContent = decryptedContent
        }
                
        if let signature = currentSignature {
            messageContent = messageContent.replacingOccurrences(of: signature, with: "")
        }
        
        messageContent = messageContent.stripOutHtml() ?? ""

        messageContent = messageContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !messageContent.isEmpty {
            return true
        }
        
        return false
    }
    
    func formattedDate(for mode: SchedulerMode) -> Date {
        switch mode {
        case .selfDestructTimer:
            guard let destructionTimer = email.destructDay else {
                return Date()
            }
            return formatterService.formatDestructionTimeStringToDateTest(date: destructionTimer) ?? Date()
        case .delayedDelivery:
            guard let delayedDeliveryDateString = email.delayedDelivery else {
                return Date()
            }
            return formatterService.formatDestructionTimeStringToDate(date: delayedDeliveryDateString) ?? Date()
        case .deadManTimer:
            guard let deadManDuration = email.deadManDuration else {
                return Date()
            }
            return formatterService.formatDeadManDurationToDate(duration: deadManDuration) ?? Date()
        }
    }
    
    // MARK: - Update
    func updateCollapseState() {
        collapsed.toggle()
        toCellVM?.updateState(collapsed)
    }
    
    func updateMenu(state: Bool, by selectedMenu: ComposeMailMenu) {
        menuCellVM?.update(menu: selectedMenu, shouldAdd: state)
        
        if let index = sections.firstIndex(of: .menu) {
            reloadSections.send(IndexSet(integer: index))
        }
    }
    
    func updateSendButtonState() {
        shouldEnableSendButton = shouldSaveDraft()
    }
    
    func removeAttachment(with contentURL: String) {
        
        func updateAttachmentCell() {
            DispatchQueue.main.async {
                Loader.stop()
                self.reloadWholeList.send()
            }
        }
        
        var existingAttachments = email.attachments ?? []
        
        guard !existingAttachments.isEmpty else {
            return
        }
        
        guard let filteredAttachment = existingAttachments.filter({ $0.contentUrl == contentURL }).first else {
            return
        }
        
        guard let id = filteredAttachment.attachmentID else {
            return
        }
        
        Loader.start()
        
        self.fetcher.deleteAttachment(withId: id.description,
                                      onCompletion:
            { [weak self] in
                DispatchQueue.main.async {
                    existingAttachments.removeAll(where: { ($0.attachmentID ?? 0) == id })
                    
                    self?.email.update(attachments: existingAttachments.isEmpty ? nil : existingAttachments)
                    
                    if let attachmentModel = self?.getMailAttachment(from: filteredAttachment) {
                        self?.attachmentCellVM?.update(attachment: attachmentModel)
                    }
                    
                    if existingAttachments.isEmpty {
                        self?.menuCellVM?.update(menu: .attachment, shouldAdd: false)
                    }
                    
                    let url = URL(fileURLWithPath: contentURL)
                    
                    FileManager.removeFile(with: url)
                    
                    updateAttachmentCell()
                    Loader.stop()
                }
        }) { (_, _) in
            DPrint("Unable to delete attachment with name: \(filteredAttachment.contentUrl ?? "")")
            updateAttachmentCell()
            Loader.stop()
        }
    }
    
    // MARK: - API Helpers
    func sendPasswordWhileCreatingMail(withPassword password: String,
                                       hint: String,
                                       expiryHours: Int,
                                       onCompletion: @escaping ((Bool) -> Void)) {
        guard let messageId = email.messsageID else {
            onCompletion(false)
            return
        }
        
        emailPassword = password
        
        let messageContent = encryptMessageWithOwnPublicKey(message: getMailContent(from: email))
        
        let encryptionObject = EncryptionObject(password: password,
                                                passwordHint: hint,
                                                expiryHours: expiryHours).toShortDictionary()
        let list = receiversList()
        
        let attachments: [[String: String]] = email.attachments?.map({ $0.toDictionary() }) ?? []
        
        let messageObject = Message(messageID: messageId.description,
                                    encryptedMessage: messageContent,
                                    encryptionObject: encryptionObject,
                                    subject: email.subject ?? "",
                                    send: false,
                                    recieversList: list,
                                    encrypted: true,
                                    subjectEncrypted: false,
                                    attachments: attachments,
                                    selfDestructionDate: email.destructDay ?? "",
                                    delayedDeliveryDate: email.delayedDelivery ?? "",
                                    deadManDate: email.deadManDuration?.description ?? "",
                                    mailboxId: mailboxId,
                                    sender: email.sender ?? "")
        
        Loader.start()
        fetcher.updateSendingMessage(withMessageObject: messageObject,
                                     onCompletion:
            { [weak self] (message) in
                if let message = message {
                    self?.email = message
                    onCompletion(true)
                } else {
                    onCompletion(false)
                }
                Loader.stop()
            }, onCompletionWithBanner: { [weak self] (bannerText) in
                Loader.stop()
                self?.showBanner.send(bannerText)
                onCompletion(false)
        }) { [weak self] (params, backToRoot) in
            Loader.stop()
            self?.showAlert.send((params, backToRoot))
            onCompletion(false)
        }
    }
    
    func updateAttachment(withURL url: URL) {
        if let messageID = email.messsageID {
            Loader.start()
            fetcher.uploadAttachment(withURL: url,
                                     messageID: messageID.description, onCompletionWithAttachment:
                { [weak self] (attachment) in
                    if let attachment = attachment {
                        
                        if var existingAttachments = self?.email.attachments {
                            existingAttachments.append(attachment)
                            self?.email.update(attachments: existingAttachments)
                        } else {
                            self?.email.update(attachments: [attachment])
                        }
                        
                        if let attachmentModel = self?.getMailAttachment(from: attachment) {
                            self?.attachmentCellVM?.update(attachment: attachmentModel)
                        }
                        
                        if let index = self?.sections.firstIndex(of: .body) {
                            self?.reloadSections.send(IndexSet(integer: index))
                        }
                        
                        self?.updateMenu(state: true, by: .attachment)
                    }
                    Loader.stop()
            }) { [weak self] (params, backToRoot) in
                self?.showAlert.send((params, backToRoot))
                Loader.stop()
            }
        }
    }
    
    func getAttachment(from url: String,
                       encrypted: Bool,
                       onCompletion: @escaping ((URL?, Bool) -> Void)) {
        Loader.start()
        fetcher.loadAttachFile(url: url,
                               encrypted: encrypted,
                               onCompletion: { (url, encrypted) in
                                Loader.stop()
                                onCompletion(url, encrypted)
                                Loader.stop()
        }) { [weak self] (params, backToRoot) in
            Loader.stop()
            self?.showAlert.send((params, backToRoot))
            onCompletion(nil, encrypted)
        }
    }
    
    func deleteDraft() {
        if let messageId = email.messsageID?.description {
            Loader.start()
            fetcher.deleteDraft(withMessageId: messageId,
                                onCompletion:
                { (_) in
                    DPrint("Draft Deleted")
                    Loader.stop()
            }) { [weak self] (params, backToRoot) in
                Loader.stop()
                self?.showAlert.send((params, backToRoot))
            }
        }
    }
    
    func saveDraft() {
        guard let messageID = email.messsageID?.description else {
            return
        }
        
        var encryptionObjectDictionary: [String: String] = [:]
        
        let encrypted = true
        
        var messageContent = getMailContent(from: email)
        
        messageContent = messageContent.replacingOccurrences(of: currentSignature ?? "", with: "")
        
        messageContent = messageContent.stripOutHtml() ?? ""
        
        messageContent = encryptMessageWithOwnPublicKey(message: messageContent)
        
        if let encryptionObject = email.encryption {
            encryptionObjectDictionary = encryptionObject.toDictionary()
        }
        
        let list = receiversList()
        
        Loader.start()
        fetcher.saveDraftMessage(messageID: messageID,
                                 messageContent: messageContent,
                                 encryptionObject: encryptionObjectDictionary,
                                 subject: email.subject ?? "",
                                 send: false,
                                 recieversList: list,
                                 encrypted: encrypted,
                                 selfDestructionDate: email.destructDay ?? "",
                                 delayedDeliveryDate: email.delayedDelivery ?? "",
                                 deadManDate: email.deadManDuration?.description ?? "",
                                 mailbox: email.mailbox,
                                 onCompletion: {
                                    Loader.stop()
        }) { [weak self] (params, backToRoot) in
            Loader.stop()
            self?.showAlert.send((params, backToRoot))
        }
    }
    
    func prepareMessadgeToSend() {
        let receivers = email.receivers ?? []
        let ccMailIds = email.cc ?? []
        let bccMailIds = email.bcc ?? []
        let sender = [email.sender].compactMap({ $0 })
        
        let allMailIds = Array(receivers + ccMailIds + bccMailIds + sender)
        
        Loader.start()
        
        fetcher.publicKeysFor(userEmailsArray: allMailIds, completion: { [weak self] (keys) in
            guard let strong = self else {
                DispatchQueue.main.async {
                    Loader.stop()
                }
                return
            }
            
            if let emailsKeys = keys {
                if emailsKeys.encrypt {
                    if let messageID = self?.email.messsageID {
                        if strong.email.attachments?.isEmpty == false, strong.includeAttachments {
                            strong.updateAttachments(publicKeys: EmailsKeys.keysModel(keys: emailsKeys.keys), messageID: messageID)
                        } else {
                            strong.sendEncryptedEmailForCtemplarUser(publicKeys: EmailsKeys.keysModel(keys: emailsKeys.keys))
                        }
                    } else {
                        let params = AlertKitParams(
                            title: Strings.AppError.error.localized,
                            message: Strings.AppError.error.localized,
                            cancelButton: Strings.Button.closeButton.localized
                        )
                        DispatchQueue.main.async {
                            Loader.stop()
                            strong.showAlert.send((params, true))
                        }
                    }
                } else {
                    strong.prepareEmailForNonCtemplarUser()
                }
            } else {
                strong.prepareEmailForNonCtemplarUser()
            }
        }) { [weak self] (params, backToRoot) in
            DispatchQueue.main.async {
                Loader.stop()
                self?.showAlert.send((params, backToRoot))
            }
        }
    }
}

public extension String {
    func stripOutHtml() -> String? {
        do {
            guard let data = self.data(using: .unicode) else {
                return nil
            }
            let attributed = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            return attributed.string
        } catch {
            return nil
        }
    }
}

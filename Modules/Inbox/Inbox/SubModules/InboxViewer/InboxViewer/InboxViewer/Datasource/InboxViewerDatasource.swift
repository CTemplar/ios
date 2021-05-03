import Foundation
import UIKit
import Utility
import Inbox
import Networking

final class InboxViewerDatasource: NSObject {
    // MARK: Properties
    private weak var inboxViewerController: InboxViewerController?
    
    private var tableView: UITableView
    
    private var message: EmailMessage?
    
    private var sections: [InboxViewerSection] = []
    
    private let apiService = NetworkManager.shared.apiService
    
    private let pgpService = UtilityManager.shared.pgpService
    
    private let formatterService = UtilityManager.shared.formatterService
    
    private (set) var lastAppliedActionMessage: EmailMessage?
    
    private (set) var lastSelectedAction: Menu.Action?
    
    private var user: UserMyself
    
    // we set a variable to hold the contentOffSet before scroll view scrolls
    var lastContentOffset: CGFloat = 0
    
    var isSpam: Bool {
        return message?.folder == Menu.spam.menuName
    }
    
    private var decryptedSubject: String {
        var subject = message?.subject ?? ""
        
        if subject.contains("BEGIN PGP") == true, let decryptedSubject = decrypt(content: subject) {
            subject = decryptedSubject
        }
        return subject
    }
    
    // MARK: - Constructor
    init(inboxViewerController: InboxViewerController, tableView: UITableView, user: UserMyself) {
        self.inboxViewerController = inboxViewerController
        self.tableView = tableView
        self.user = user
        super.init()
        
        setupTableView()
    }
    
    // MARK: - Update
    func update(by message: EmailMessage?) {
        self.message = message
        inboxViewerController?.setup(message: message)
        setupData()
    }
    
    func update(lastSelectedAction: Menu.Action?) {
        self.lastSelectedAction = lastSelectedAction
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = false
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemBackground
        tableView.backgroundView = backgroundView
        
        tableView.register(InboxViewerSubjectCell.self, forCellReuseIdentifier: InboxViewerSubjectCell.className)
        tableView.register(InboxViewerTextMailBodyCell.self, forCellReuseIdentifier: InboxViewerTextMailBodyCell.className)
        tableView.register(UINib(nibName: InboxViewerWebMailBodyCell.className, bundle: Bundle(for: InboxViewerWebMailBodyCell.self)), forCellReuseIdentifier: InboxViewerWebMailBodyCell.className)
        tableView.register(AttachmentCell.self, forCellReuseIdentifier: AttachmentCell.className)
    }
    
    private func setupData() {
        guard let messageObject = message else {
            return
        }
        
        // Subject
        let isProtected = messageObject.isProtected ?? false
        let isStarred = messageObject.starred ?? false
        let isSecured = true

        var sectionList: [InboxViewerSection] = [
            .subject(Subject(
                title: decryptedSubject,
                isProtected: isProtected,
                isSecured: isSecured,
                isStarred: isStarred
                )
            )
        ]
        
        // Mail Body
        if var children = messageObject.children, !children.isEmpty {
            // Append Parent
            children.append(messageObject)
            
            children = children.sorted(by: { (m1, m2) -> Bool in
                if let createdDateString1 = m1.createdAt, let createdDateString2 = m2.createdAt {
                    if let date1 = formatterService.formatStringToDate(date: createdDateString1),
                       let date2 = formatterService.formatStringToDate(date: createdDateString2) {
                        return date1.compare(date2) == .orderedAscending
                    }
                }
                return false
            })
            
            for (index, child) in children.enumerated() {
                if let content = getDecryptedContent(from: child) {
                    sectionList.append(.mailBody(TextMail(messageId: child.messsageID,
                                                          content: content,
                                                          state: (index == children.count - 1) ? .expanded : .collapsed,
                                                          shouldBlockExternalImages: user.settings.blockExternalImage ?? false),
                                                 child.isHtml ?? false)
                    )
                }
            }
        } else {
            if let content = getDecryptedContent(from: messageObject) {
                sectionList.append(.mailBody(TextMail(messageId: messageObject.messsageID,
                                                      content: content,
                                                      state: .expanded,
                                                      shouldBlockExternalImages: user.settings.blockExternalImage ?? false),
                                             messageObject.isHtml ?? false)
                )
            }
        }
        
        // Attachments
        if let attachments = messageObject.attachments, !attachments.isEmpty {
            var attachmentModels: [MailAttachment] = []
            attachments.forEach({
                if let url = $0.contentUrl,
                    let fileName = FileManager.fileName(fileUrl: url),
                    let fileExtension = FileManager.fileExtension(fileUrl: url) {
                    if let extensionType = GeneralConstant.DocumentsExtension(rawValue: fileExtension.lowercased()) {
                        let attachment = MailAttachment(attachmentTitle: fileName,
                                                        attachmentType: extensionType,
                                                        contentURL: url,
                                                        encrypted: $0.encrypted ?? false)
                        attachmentModels.append(attachment)
                    }
                    else {
                        if fileExtension == "__", $0.name?.components(separatedBy: ".").count ?? 0 > 1, let newExtensionType = $0.name?.components(separatedBy: ".")[1], let extensionType = GeneralConstant.DocumentsExtension(rawValue: newExtensionType.lowercased()) {
                            let attachment = MailAttachment(attachmentTitle: fileName,
                                                            attachmentType: extensionType,
                                                            contentURL: url,
                                                            encrypted: $0.encrypted ?? false)
                            attachmentModels.append(attachment)
                        }
                    }
                    
                   
                }
            })
            let model = MailAttachmentCellModel(attachments: attachmentModels)
            sectionList.append(.attachment(model))
        }
        
        sections = sectionList
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Datasource Helpers
    
    private func getDecryptedContent(from message: EmailMessage) -> String? {
        if let content = message.content {
            if apiService.isMessageEncrypted(message: message) == true {
                let decryptedContent = pgpService.decryptMessage(encryptedContet: content)
                return decryptedContent
            } else {
                return content
            }
        }
        return nil
    }

    func getHeaderModel(withMessageId messageId: Int?, state: InboxHeaderState) -> InboxViewerMailSenderHeader? {
        var message: EmailMessage?
        
        let shouldHeaderTappable = self.message?.children?.isEmpty == false
        
        if let child = self.message?.children?.first(where: { $0.messsageID == messageId }) {
            message = child
        } else {
            message = self.message
        }
        
        guard let messageObj = message else {
            return nil
        }
        
        // Sender Name
        var sender = ""
        
        if let senderName = messageObj.sender_display,
            !senderName.isEmpty {
            sender = senderName
        } else if let senderEmail = messageObj.sender,
            !senderEmail.isEmpty {
            sender = senderEmail
        }
        
        // Receiver's Mail Id(s)
        var receiver = ""
        
        if let recievers = messageObj.receivers, !recievers.isEmpty {
            receiver = formatterService.formatToString(toEmailsArray: recievers)
        }
        
        // Date
        var dateText = ""
        if let createdDate = messageObj.createdAt {
            if let date = formatterService.formatStringToDate(date: createdDate) {
                dateText = formatterService.formatCreationDate(date: date, short: false, useFullDate: true)
            }
        }
        
        let headerModel = InboxViewerMailSenderHeader(senderName: sender,
                                                      receiverEmailId: receiver,
                                                      mailSentDate: dateText,
                                                      detailMailIdsWithAttribute: getMailSenderTypes(from: messageObj),
                                                      emailProperty: getMailProperty(from: messageObj),
                                                      folder: messageObj.folder?.firstUppercased ?? "N/A",
                                                      isTappable: shouldHeaderTappable,
                                                      state: state)
        return headerModel
    }
    
    private func getMailSenderTypes(from message: EmailMessage) -> [SenderType] {
        var senderTypes: [SenderType] = []
        
        if let sender = message.sender, !sender.isEmpty {
            let fromEmailText = Strings.Formatter.fromPrefix.localized
            let formattedSender = "\(fromEmailText)<\(sender)>"
            senderTypes.append(.from(formattedSender))
        }
        
        if let recievers = message.receivers, !recievers.isEmpty {
            let receiver = formatterService.formatToString(toEmailsArray: recievers)
            senderTypes.append(.to(receiver))
        }
        
        if let ccMailIds = message.cc, !ccMailIds.isEmpty {
            let cc = formatterService.formatToString(toEmailsArray: ccMailIds)
            senderTypes.append(.cc(cc))
        }
        
        if let bccMailIds = message.bcc, !bccMailIds.isEmpty {
            let bcc = formatterService.formatToString(toEmailsArray: bccMailIds)
            senderTypes.append(.bcc(bcc))
        }
        
        return senderTypes
    }
    
    private func getMailProperty(from message: EmailMessage) -> EmailProperty? {
        var leftAttributedText = NSAttributedString(string: "")
        var rightAttributedText = NSAttributedString(string: "")
        var leftViewBackgroundColor = UIColor.clear
        var rightViewBackgroundColor = UIColor.clear
        
        if let delayedDelivery = message.delayedDelivery {
            leftViewBackgroundColor = k_greenColor
            
            if let date = formatterService.formatDestructionTimeStringToDate(date: delayedDelivery) {
                leftAttributedText = date.timeCountForDelivery(short: false)
            } else {
                if let date = formatterService.formatDestructionTimeStringToDateTest(date: delayedDelivery) {
                    leftAttributedText = date.timeCountForDelivery(short: false)
                } else {
                    leftAttributedText = NSAttributedString(string: Strings.AppError.error.localized)
                }
            }
        }
        
        if let deadManDuration = message.deadManDuration {
            leftViewBackgroundColor = k_redColor
            leftAttributedText = formatterService.formatDeadManDateString(duration: deadManDuration, short: false)
        }
        
        if let destructionDate = message.destructDay {
            rightViewBackgroundColor = k_orangeColor
            
            if let date = formatterService.formatDestructionTimeStringToDate(date: destructionDate) {
                rightAttributedText = date.timeCountForDestruct(short: false)
            } else {
                if let date = formatterService.formatDestructionTimeStringToDateTest(date: destructionDate) {
                    rightAttributedText = date.timeCountForDestruct(short: false)
                } else {
                    rightAttributedText = NSAttributedString(string: Strings.AppError.error.localized)
                }
            }
        }
        
        let property = EmailProperty(timerText: leftAttributedText,
                                     deleteText: rightAttributedText,
                                     timerBackgroundColor: leftViewBackgroundColor,
                                     deleteBackgroundColor: rightViewBackgroundColor)
        return property
    }
    
    func undo(lastMessage: EmailMessage) {
        inboxViewerController?.presenter?.hideUndoBar()
        
        guard let lastAppliedAction = self.lastSelectedAction else {
            return
        }
        
        switch lastAppliedAction {
        case .markAsSpam:
            inboxViewerController?
                .presenter?
                .interactor?
                .markMessagesAsSpam(lastSelectedMessage: lastMessage,
                                    withUndo: ""
            )
        case .markAsRead:
            inboxViewerController?
                .presenter?
                .interactor?
                .toggleReadStatus(lastSelectedMessage: lastMessage,
                                  asRead: (lastMessage.read ?? false),
                                  withUndo: ""
            )
        case .moveToArchive:
            inboxViewerController?
                .presenter?
                .interactor?
                .markMessagesAsArchived(lastSelectedMessage: lastMessage,
                                        withUndo: ""
            )
        case .moveToTrash:
            inboxViewerController?
                .presenter?
                .interactor?
                .markMessagesAsTrash(lastSelectedMessage: lastMessage,
                                     withUndo: ""
            )
        case .moveToInbox:
            inboxViewerController?
                .presenter?
                .interactor?
                .moveMessagesToInbox(lastSelectedMessage: lastMessage,
                                     withUndo: "")
        case .markAsStarred:
            inboxViewerController?
                .presenter?
                .interactor?
                .markMessageAsStarred(message: lastMessage,
                                      starred: message?.starred ?? false,
                                      withUndo: "", onCompletion: nil)
        case .moveTo,
             .delete,
             .noAction: break
        }
        
        update(lastSelectedAction: nil)
    }
    
    func needReadAction() -> Bool {
        return message?.read ?? false
    }
    
    func decrypt(content: String) -> String? {
        let decryptedSubject = pgpService.decryptMessage(encryptedContet: content)
        if decryptedSubject == "#D_FAILED_ERROR#" {
            return nil
        }
        return decryptedSubject
    }
}

// MARK: - UITableViewDelegate & UITableViewDatasource
extension InboxViewerDatasource: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard sections.count > section else {
            return 0
        }
        
        let sectionType = sections[section]
        
        switch sectionType {
        case .mailBody(let textMail, _):
            return textMail.state == .collapsed ? 0 : 1
        case .subject:
            return 1
        case .attachment:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard sections.count > indexPath.section else {
            return UITableViewCell()
        }
        
        let sectionType = sections[indexPath.section]
        
        switch sectionType {
        case .subject(let subject):
            return configureSubjectCell(with: subject, indexPath: indexPath)
        case .mailBody(let content, let isHTMLContent):
            if isHTMLContent {
                return configureWebMailBodyCell(with: content, indexPath: indexPath)
            } else {
                return configureTextMailBodyCell(with: content, indexPath: indexPath)
            }
        case .attachment(let attachmentModel):
            return configureAttachmentCell(with: attachmentModel, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard sections.count > section else {
            return UIView()
        }
        
        let sectionType = sections[section]
        
        switch sectionType {
        case .mailBody(let textMail, let isHTML):
            var model = textMail
            let headerView = InboxViewerMailSenderHeaderView()
            
            if let headerModel = getHeaderModel(withMessageId: textMail.messageId, state: textMail.state) {
                headerView.configure(with: headerModel)
            }
            
            headerView.onTapHeader = { [weak self] (state) in
                model.update(state: state)
                
                self?.sections[section] = .mailBody(model, isHTML)
//                UIView.performWithoutAnimation {
//                    self?.tableView.reloadData()
//
//                }
                DispatchQueue.main.async {
                    let loc = self?.tableView.contentOffset
                    UIView.performWithoutAnimation {
                        self?.tableView.layoutIfNeeded()
                        self?.tableView.reloadData()
                       // tableView.reloadSections(IndexSet(integer: section), with: .none)
                        self?.tableView.layer.removeAllAnimations()
                    }
                    self?.tableView.setContentOffset(loc ?? .zero, animated: false)
                    
                }
               // self?.tableView.reloadData()
                //
            }
            
            headerView.onTapViewDetails = { (isSelected) in
                UIView.performWithoutAnimation {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
//                tableView.beginUpdates()
//                tableView.endUpdates()
            }
            
            return headerView
        case .attachment,
             .subject:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        guard sections.count > section else {
            return 0.0
        }
        
        let sectionType = sections[section]
        
        switch sectionType {
        case .mailBody:
            return 80.0
        case .attachment,
             .subject:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard sections.count > section else {
            return 0.0
        }
        
        let sectionType = sections[section]
        
        switch sectionType {
        case .mailBody:
            return UITableView.automaticDimension
        case .attachment,
             .subject:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard sections.count > indexPath.section else {
            return 0.0
        }
        
        let sectionType = sections[indexPath.section]
        
        switch sectionType {
        case .mailBody, .subject:
            return UITableView.automaticDimension
        case .attachment:
             return 80.0
        }
        
        
//        func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//            guard let videoCell = cell as? InboxViewerWebMailBodyCell else {
//                return
//            }
//            videoCell.isLoaded = true
//        }
    }
    
    // MARK: - Cell Configurations
    private func configureSubjectCell(with subject: Subject,
                                      indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InboxViewerSubjectCell.className,
                                                       for: indexPath) as? InboxViewerSubjectCell else {
                                                        return UITableViewCell()
        }
        cell.configure(with: subject)
        cell.onTapStar = { [weak self] (isStarred) in
            guard let safeSelf = self,
                let msg = safeSelf.message else {
                    return
            }
            self?.inboxViewerController?
                .presenter?
                .interactor?
                .markMessageAsStarred(message: msg,
                                      starred: !isStarred,
                                      withUndo: "",
                                      onCompletion:
                    { (status, error) in
                        if error == nil {
                            safeSelf
                                .message?
                                .update(isStarred: status)
                            cell.update(isStarred: status)
                        }
                })
        }
        return cell
    }
    
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y <= 10.0 {
//            inboxViewerController?.navigationItem.title = nil
//        } else if scrollView.contentOffset.y > 15 {
//            inboxViewerController?.navigationItem.title = decryptedSubject
//        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 10.0 {
            inboxViewerController?.navigationItem.title = nil
        } else if scrollView.contentOffset.y > 15 {
            inboxViewerController?.navigationItem.title = decryptedSubject
        }
    }

    private func configureTextMailBodyCell(with content: TextMail,
                                           indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InboxViewerTextMailBodyCell.className,
                                                       for: indexPath) as? InboxViewerTextMailBodyCell else {
                                                        return UITableViewCell()
        }
        cell.configure(with: content)
        return cell
    }
    
    private func configureWebMailBodyCell(with content: TextMail,
                                          indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: InboxViewerWebMailBodyCell.className,
//                                                       for: indexPath) as? InboxViewerWebMailBodyCell else {
//                                                        return UITableViewCell()
//        }
        
//        guard let cell = UITableViewCell(style: .default, reuseIdentifier: InboxViewerWebMailBodyCell.className) as? InboxViewerWebMailBodyCell else {
//                                                                    return UITableViewCell()
//                    }
        
//        guard  let cell = Bundle(for: InboxViewerWebMailBodyCell.self).loadNibNamed(InboxViewerWebMailBodyCell.className, owner: self, options: nil)?[0] as? InboxViewerWebMailBodyCell else {
//            return UITableViewCell()
//        }

        let nibs = Bundle(for: InboxViewerWebMailBodyCell.self).loadNibNamed(InboxViewerWebMailBodyCell.className, owner: self, options: nil)
        
        guard let cell = nibs?[0] as? InboxViewerWebMailBodyCell else{
            return UITableViewCell()
        }
        
        cell.configure(with: content)
        cell.onHeightChange = { [weak self] in
            
//            DispatchQueue.main.async {
//                UIView.performWithoutAnimation {
//                    self?.tableView.beginUpdates()
//                    self?.tableView.endUpdates()
//                }
////                self?.tableView.beginUpdates()
////                self?.tableView.endUpdates()
//               // self?.tableView.reloadData()
//            }
           
            DispatchQueue.main.async {
                let loc = self?.tableView.contentOffset
                UIView.performWithoutAnimation {
                    self?.tableView.layoutIfNeeded()
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                    self?.tableView.layer.removeAllAnimations()
                }
                self?.tableView.setContentOffset(loc ?? .zero, animated: false)
                
            }
        }
        return cell
    }
    
    
    
    private func configureAttachmentCell(with attachmentModel: MailAttachmentCellModel,
                                         indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AttachmentCell.className,
                                                       for: indexPath) as? AttachmentCell else {
                                                        return UITableViewCell()
        }
        
        cell.configure(with: attachmentModel)
        
        // Attachment Handler
        cell.onTapAttachment = { [weak self] (contentURLString, encrypted, newUrl) in
           
                let url = FileManager.getFileUrlDocuments(withURLString: contentURLString)
                
                if FileManager.checkIsFileExist(url: url) == true {
                    self?.inboxViewerController?
                        .presenter?
                        .showPreviewScreen(url: url, encrypted: encrypted, newUrl: newUrl)
                } else {
                    self?.inboxViewerController?
                        .presenter?
                        .interactor?
                        .loadAttachFile(url: contentURLString, encrypted: encrypted, newUrl: newUrl)
                }
        }
        return cell
    }
}

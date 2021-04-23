import Foundation
import Networking
import Utility

final class InboxInteractor {
    // MARK: Properties
    private (set) var loadMoreInProgress = false
    
    private (set) weak var viewController: InboxViewController?
    
    private (set) weak var presenter: InboxPresenter?
    
    private var isFetchInProgress = false
    
    private let apiService = NetworkManager.shared.apiService
    
    private let pgpService = UtilityManager.shared.pgpService
    
    private (set) var offset = 0
    
    private (set) var totalItems = 0
    private (set) var apiCalled = false
    
    // MARK: - Constructor
    init(viewController: InboxViewController) {
        self.viewController = viewController
    }
    
    func update(offset: Int) {
        self.offset = offset
    }
    
    func update(totalItems: Int) {
        self.totalItems = totalItems
    }
    
    func update(presenter: InboxPresenter) {
        self.presenter = presenter
    }
    
    func toggleProgress(_ isInProgress: Bool) {
        loadMoreInProgress = isInProgress
    }
    
    // MARK: - API Calls
    @discardableResult
    func messagesList(folder: String, withUndo: String, silent: Bool) -> Bool {
      //  offset = self.viewController?.dataSource?.messages.count ?? 0
        if (apiCalled == true) {
            return true
        }
        if offset >= totalItems, offset > 0 {
            return false
        }
        
        if isFetchInProgress {
            return false
        }
        self.apiCalled = true
        // Start the loader
        if !silent {
            DispatchQueue.main.async {
                Loader.start()
            }
        }
        
        let pageSize: Int
        
        // Set the page size
        if viewController?
            .dataSource?
            .messagesAvailable == false {
            pageSize = Device.IS_IPAD ? PageLimit.bigDeviceOffset.rawValue : PageLimit.smallDeviceOffset.rawValue
        } else {
            pageSize = PageLimit.generalThreshold.rawValue
        }
        
       
        // Fetch the latest emails
        apiService.messagesList(folder: folder,
                                messagesIDIn: "",
                                seconds: 0,
                                offset: offset,
                                pageLimit: pageSize)
        { [weak self] (result) in
            
            DispatchQueue.main.async  {
                self?.apiCalled = false
            }
            guard let self = self else {
                DispatchQueue.main.async {
                    Loader.stop()
                }
                return
            }
            
            DispatchQueue.main.async  {
                // Set the inbox data
               
                self.setInboxData(from: result,
                                  withUndo: withUndo,
                                  withPageSize: pageSize,
                                  wasSilent: silent
                )
            }
        }
        return true
    }
    
    /// Fetches the latest updates of the mailbox list
    /// - Parameters:
    ///    - storeKeys: An identifier which tells us whether we need to save the updated private-public key pair.
    private func mailboxesList(storeKeys: Bool) {
        apiService.mailboxesList() { [weak self] (result) in
            switch(result) {
            case .success(let value):
                guard let mailboxes = value as? Mailboxes else {
                    return
                }
                
                if let mailboxList = mailboxes.mailboxesResultsList {
                    // Update the inbox data source
                    self?.viewController?.dataSource?.update(mailboxList: mailboxList)
                    // Save the keys conditionally
                    if (mailboxList.count > 0) {
                        Mailbox.getKeysModel(keysArray: mailboxList)
                    }
//                    for mailbox in mailboxList {
//                        if storeKeys {
//                            if let privateKey = mailbox.privateKey {
//                                self?.pgpService.extractAndSavePGPKeyFromString(key: privateKey)
//                            }
//
//                            if let publicKey = mailbox.publicKey {
//                                self?.pgpService.extractAndSavePGPKeyFromString(key: publicKey)
//                            }
//                        }
//                    }
                        NotificationCenter.default.post(name: .updateInboxMessagesNotificationID, object: nil)
                    // Inbox list update notification
                }
                
            case .failure(let error):
                DPrint("error:", error)
                // Show alert if the API fails
                self?.viewController?.showAlert(with: Strings.AppError.mailBoxesError.localized,
                                                message: error.localizedDescription,
                                                buttonTitle: Strings.Button.closeButton.localized
                )
            }
        }
    }
    
    /// Fetches the latest update of the current user
    func userMyself(_ onCompletion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            self.apiService.userMyself() { [weak self] (result) in
                switch(result) {
                case .success(let value):
                    guard var userMyself = value as? UserMyself else {
                        return
                    }
                    
                    // Update Contacts
                    if userMyself.username == self?.viewController?.dataSource?.user.username,
                        let contactsList = self?.viewController?.dataSource?.user.contactsList {
                        userMyself.update(contactsList: contactsList)
                    }
                    
                    // Update User instance
                    self?.viewController?.dataSource?.update(user: userMyself)
                    
                    // Update user's mail box
                    if let mailboxes = userMyself.mailboxesList {
                        self?.viewController?.dataSource?.update(mailboxList: mailboxes)
                    }
                    
                    // User update notification
                        NotificationCenter.default.post(name: .updateUserDataNotificationID, object: value)
                    
                    // Fetch latest contacts
                    self?.userContactsList()
                case .failure(let error):
                    DPrint("error:", error)
                    // Show alert if the API fails
                    self?.viewController?.showAlert(with: Strings.AppError.userError.localized,
                                                    message: error.localizedDescription,
                                                    buttonTitle: Strings.Button.closeButton.localized
                    )
                }
                
                onCompletion?()
            }
        }
    }
    
    /// Updates the user contacts list
    func userContactsList() {
        guard viewController?
            .dataSource?
            .user
            .contactsList?.isEmpty == false else {
                return
        }
        
        DispatchQueue.global(qos: .background).async {
            self.apiService.userContacts(fetchAll: true,
                                         offset: 0,
                                         silent: true)
            { [weak self] (result) in
                switch result {
                case .success(let value):
                    if let contactsList = value as? ContactsList {
                        self?.viewController?
                            .dataSource?
                            .update(
                                contacts: contactsList
                        )
                    }
                    break
                case .failure(let error):
                    DPrint("Error in fetching user contacts: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - API Callers or Application Logics
extension InboxInteractor {
    func updateMessages(withUndo: String, silent: Bool, menu: MenuConfigurable?) {
        guard let menu = menu else {
            return
        }
        
        
        
        if (UserDefaults.standard.value(forKey: "keysArray") as? Data) != nil {
            DPrint("local PGPKeys exist")
            //totalItems = 0
            DispatchQueue.global(qos: .background).async {
                self.messagesList(folder: menu.menuName,
                                   withUndo: withUndo,
                                   silent: silent)
            }
        }
        else {
            DispatchQueue.global(qos: .background).async {
                self.mailboxesList(storeKeys: true)
            }
        }
        
        
//        if pgpService.getStoredPGPKeys() == nil {
//            DispatchQueue.global(qos: .background).async {
//                self.mailboxesList(storeKeys: true)
//            }
//        } else {
//            DPrint("local PGPKeys exist")
//            totalItems = 0
//            DispatchQueue.global(qos: .background).async {
//                self.messagesList(folder: menu.menuName,
//                                   withUndo: withUndo,
//                                   silent: silent)
//            }
//        }
    }
    
    private func setInboxData(from result: APIResult<Any>,
                              withUndo undoMessage: String,
                              withPageSize pageSize: Int,
                              wasSilent silent: Bool) {
        isFetchInProgress = false
        
        if loadMoreInProgress {
            loadMoreInProgress = false
            viewController?.dataSource?.resetFooterView()
        }
        
        DispatchQueue.main.async {
            Loader.stop()
        }
        
        switch(result) {
        case .success(let value):
            if let emailMessages = value as? EmailMessagesList {
               // totalItems = emailMessages.totalCount ?? 0
                print("============== messages count: \(totalItems) =====================")
                self.totalItems = emailMessages.totalCount ?? 0
                viewController?
                    .dataSource?
                    .setInboxData(by: emailMessages.messagesList ?? [],
                                  withTotalCount: totalItems,
                                  pageOffset: offset
                )
                if !undoMessage.isEmpty {
                    presenter?.showUndoBar(text: undoMessage)
                }
                offset += pageSize
            }
        case .failure(let error):
            DPrint("error:", error)
            if !silent {
                self.viewController?.showAlert(with: Strings.AppError.messagesError.localized,
                                               message: error.localizedDescription,
                                               buttonTitle: Strings.Button.closeButton.localized
                )
            }
        }
        DPrint("messagesList complete")
        Loader.stop()
    }
}

// MARK: - Swipe Interactions
extension InboxInteractor {
    func showMoveTo(message: EmailMessage) {
        if let messageId = message.messsageID {
            viewController?.router?.showMoveToController(withSelectedMessages: [messageId])
        }
    }
    
    func markMessageAsSpam(message: EmailMessage) {
        guard let id = message.messsageID else {
            return
        }
        markMessagesAsSpam(forMessageIds: [id],
                           lastSelectedMessage: message,
                           withUndo: Strings
                            .Inbox
                            .UndoAction
                            .undoMarkAsSpam
                            .localized
        )
    }
    
    func markMessageAsRead(message: EmailMessage) {
        guard let id = message.messsageID,
            let readStatus = message.read else {
                return
        }
        
        let undoMessage = readStatus == true ?
            Strings.Inbox.UndoAction.undoMarkAsUnread.localized :
            Strings.Inbox.UndoAction.undoMarkAsRead.localized
        
        toggleReadStatus(forMessageIds: [id], asRead: readStatus, withUndo: undoMessage)
    }
    
    func markMessageAsTrash(message: EmailMessage) {
        guard let id = message.messsageID else {
            return
        }
        
        if SharedInboxState.shared.selectedMenu?.menuName == Menu.trash.menuName {
            delete(messageIds: [id], withUndo: "")
        } else {
            markMessagesAsTrash(forMessageIds: [id],
                                lastSelectedMessage: message,
                                withUndo: Strings.Inbox.UndoAction.undoMoveToTrash.localized
            )
        }
    }
    
    func undoLastAction(message: EmailMessage) {
        viewController?.dataSource?.undo(lastMessage: message)
    }
}

// MARK: - More Action Interactions
extension InboxInteractor {
    func toggleReadStatus(forMessageIds messageIds: [Int],
                          asRead: Bool,
                          withUndo: String) {
        var messagesIDList = ""
        
        for message in messageIds {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex))
        
        Loader.start()

        apiService.updateMessages(messageID: "",
                                  messagesIDIn: messagesIDList,
                                  folder: "",
                                  starred: false,
                                  read: asRead,
                                  updateFolder: false,
                                  updateStarred: false,
                                  updateRead: true)
        { [weak self] (result) in
            guard let weakSelf = self else {
                return
            }
            DispatchQueue.main.async {
                Loader.stop()
            }
            switch(result) {
            case .success( _):
                DPrint("marked list as read/unread")
                weakSelf.viewController?.dataSource?.update(lastSelectedAction: .markAsRead)
                weakSelf.offset = 0
                weakSelf.updateMessages(withUndo: withUndo, silent: false, menu: SharedInboxState.shared.selectedMenu)
            case .failure(let error):
                DPrint("error:", error)
                weakSelf.viewController?.showAlert(with: Strings.AppError.messagesError.localized,
                                                   message: error.localizedDescription,
                                                   buttonTitle: Strings.Button.closeButton.localized
                )
            }
        }
    }
    
    func delete(messageIds: [Int], withUndo: String) {
        var messagesIDList : String = ""
        
        for message in messageIds {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex))
        
        Loader.start()

        apiService.deleteMessages(messagesIDIn: messagesIDList) { [weak self] (result) in
            guard let weakSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                Loader.stop()
            }
            
            switch(result) {
            case .success( _):
                DPrint("deleteMessagesList")
                weakSelf.viewController?.dataSource?.update(lastSelectedAction: .delete)
                weakSelf.offset = 0
                weakSelf.updateMessages(withUndo: withUndo, silent: false, menu: SharedInboxState.shared.selectedMenu)
            case .failure(let error):
                print("error:", error)
                weakSelf.viewController?.showAlert(with: Strings.AppError.messagesError.localized,
                                                   message: error.localizedDescription,
                                                   buttonTitle: Strings.Button.closeButton.localized
                )
            }
        }
    }
    
    func markMessagesAsTrash(forMessageIds messageIds: [Int],
                             lastSelectedMessage: EmailMessage,
                             withUndo: String) {
        guard let folder = withUndo.isEmpty == false ?
            MessagesFoldersName.trash.rawValue :
            lastSelectedMessage.folder else {
                return
        }
        
        var messagesIDList = ""
        
        for message in messageIds {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex))
        
        Loader.start()

        apiService.updateMessages(messageID: "",
                                  messagesIDIn: messagesIDList,
                                  folder: folder,
                                  starred: false,
                                  read: false,
                                  updateFolder: true,
                                  updateStarred: false,
                                  updateRead: false)
        { [weak self] (result) in
            guard let weakSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                Loader.stop()
            }
            
            switch(result) {
            case .success( _):
                DPrint("marked list as trash")
                weakSelf.viewController?.dataSource?.update(lastSelectedAction: .moveToTrash)
                weakSelf.offset = 0
                weakSelf.updateMessages(withUndo: withUndo, silent: false, menu: SharedInboxState.shared.selectedMenu)
            case .failure(let error):
                DPrint("error:", error)
                weakSelf.viewController?.showAlert(with: Strings.AppError.messagesError.localized,
                                                   message: error.localizedDescription,
                                                   buttonTitle: Strings.Button.closeButton.localized
                )
            }
        }
    }
    
    func markMessagesAsArchived(forMessageIds messageIds: [Int],
                                lastSelectedMessage: EmailMessage,
                                withUndo: String) {
        guard let folder = withUndo.isEmpty == false ?
            MessagesFoldersName.archive.rawValue :
            lastSelectedMessage.folder else {
                return
        }
        
        let isStarred = lastSelectedMessage.starred ?? false
        
        let isRead = lastSelectedMessage.read ?? false
        
        var messagesIDList = ""
        
        for message in messageIds {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex))
        
        Loader.start()

        apiService.updateMessages(messageID: "",
                                  messagesIDIn: messagesIDList,
                                  folder: folder,
                                  starred: isStarred,
                                  read: isRead,
                                  updateFolder: true,
                                  updateStarred: false,
                                  updateRead: false)
        { [weak self] (result) in
            guard let weakSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                Loader.stop()
            }
            
            switch(result) {
            case .success( _):
                DPrint("move list to archive")
                weakSelf.viewController?.dataSource?.update(lastSelectedAction: .moveToArchive)
                weakSelf.offset = 0
                weakSelf.updateMessages(withUndo: withUndo, silent: false, menu: SharedInboxState.shared.selectedMenu)
            case .failure(let error):
                DPrint("error:", error)
                weakSelf.viewController?.showAlert(with: Strings.AppError.messagesError.localized,
                                                   message: error.localizedDescription,
                                                   buttonTitle: Strings.Button.closeButton.localized
                )
            }
        }
    }
    
    func markMessagesAsSpam(forMessageIds messageIds: [Int],
                            lastSelectedMessage: EmailMessage,
                            withUndo: String) {
        Loader.start()
        
        let folder = withUndo.isEmpty == false ?
            MessagesFoldersName.spam.rawValue :
            lastSelectedMessage.folder ?? Menu.inbox.rawValue
        
        var messagesIDList = ""
        
        for message in messageIds {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex))
        
        apiService.updateMessages(messageID: "",
                                  messagesIDIn: messagesIDList,
                                  folder: folder,
                                  starred: false,
                                  read: false,
                                  updateFolder: true,
                                  updateStarred: false,
                                  updateRead: false)
        { [weak self] (result) in
            guard let weakSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                Loader.stop()
            }
            
            switch(result) {
            case .success( _):
                DPrint("marked list as spam")
                weakSelf.viewController?.dataSource?.update(lastSelectedAction: .markAsSpam)
                weakSelf.offset = 0
                weakSelf.updateMessages(withUndo: withUndo, silent: false, menu: SharedInboxState.shared.selectedMenu)
            case .failure(let error):
                DPrint("error:", error)
                weakSelf.viewController?.showAlert(with: Strings.AppError.messagesError.localized,
                                                   message: error.localizedDescription,
                                                   buttonTitle: Strings.Button.closeButton.localized
                )
            }
        }
    }
    
    func moveMessagesToInbox(messageIds: [Int],
                             lastSelectedMessage: EmailMessage,
                             withUndo: String) {
        guard let folder = withUndo.isEmpty == false ?
            MessagesFoldersName.inbox.rawValue :
            lastSelectedMessage.folder else {
                return
        }
        
        let isStarred = lastSelectedMessage.starred ?? false
        
        let isRead = lastSelectedMessage.read ?? false
        
        var messagesIDList = ""
        
        for message in messageIds {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex))
        
        Loader.start()

        apiService.updateMessages(messageID: "",
                                  messagesIDIn: messagesIDList,
                                  folder: folder,
                                  starred: isStarred,
                                  read: isRead,
                                  updateFolder: true,
                                  updateStarred: false,
                                  updateRead: false)
        { [weak self] (result) in
            guard let weakSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                Loader.stop()
            }
            
            switch(result) {
            case .success( _):
                DPrint("move list to inbox")
                weakSelf.viewController?.dataSource?.update(lastSelectedAction: .moveToInbox)
                weakSelf.offset = 0
                weakSelf.updateMessages(withUndo: withUndo, silent: false, menu: SharedInboxState.shared.selectedMenu)
            case .failure(let error):
                DPrint("error:", error)
                weakSelf.viewController?.showAlert(with: Strings.AppError.messagesError.localized,
                                                   message: error.localizedDescription,
                                                   buttonTitle: Strings.Button.closeButton.localized
                )
            }
        }
    }
}

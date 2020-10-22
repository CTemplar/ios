import Foundation
import Networking
import Utility
import Inbox

final class InboxViewerInteractor {
    // MARK: Properties
    private let apiService = NetworkManager.shared.apiService
    private (set) weak var inboxViewerController: InboxViewerController?
    
    // MARK: - Setup
    func setup(inboxViewerController: InboxViewerController?) {
        self.inboxViewerController = inboxViewerController
    }
        
    // MARK: - API calls
    func getMessage(messageID: Int) {
        Loader.start()
        apiService.messagesList(folder: "",
                                messagesIDIn: messageID.description,
                                seconds: 0, offset: -1)
        { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch(result) {
                case .success(let value):
                    if let emailMessages = value as? EmailMessagesList,
                        let messages = emailMessages.messagesList,
                        let message = messages.first {
                        self?.inboxViewerController?.dataSource?.update(by: message)
                        self?.inboxViewerController?.presenter?.toggleReplyAll(shouldHide: (message.receivers ?? []).count < 3)
                        self?.inboxViewerController?
                            .dataSource?
                            .update(lastSelectedAction: .markAsRead)
                        self?.inboxViewerController?
                            .viewInboxDelegate?
                            .didUpdateReadStatus(for: message, status: true)
                    } else {
                        self?.inboxViewerController?
                            .presenter?
                            .showAlert(withTitle: Strings.AppError.error.localized,
                                       desc: Strings.AppError.messagesError.localized,
                                       buttonTitle: Strings.Button.closeButton.localized)
                        self?.inboxViewerController?.router?.backToParent()
                    }
                case .failure(let error):
                    self?.inboxViewerController?
                        .presenter?
                        .showAlert(withTitle: Strings.AppError.messagesError.localized,
                                   desc: error.localizedDescription,
                                   buttonTitle: Strings.Button.closeButton.localized)
                    self?.inboxViewerController?.router?.backToParent()
                }
            }
        }
    }
    
    func loadAttachFile(url: String, encrypted: Bool) {
        Loader.start()
        apiService.loadAttachFile(url: url) { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch(result) {
                case .success(let value):
                    if let savedFileUrl = value as? URL {
                        self?.inboxViewerController?
                            .presenter?
                            .showPreviewScreen(url: savedFileUrl, encrypted: encrypted
                        )
                    } else {
                        self?.inboxViewerController?
                            .presenter?
                            .showAlert(withTitle: Strings.AppError.unknownError.localized,
                                       desc: Strings.AppError.error.localized,
                                       buttonTitle: Strings.Button.closeButton.localized
                        )
                    }
                case .failure(let error):
                    self?.inboxViewerController?
                        .presenter?
                        .showAlert(withTitle: Strings.AppError.fileDownloadError.localized,
                                   desc: error.localizedDescription,
                                   buttonTitle: Strings.Button.closeButton.localized
                    )
                }
            }
        }
    }
    
    func markMessageAsStarred(message: EmailMessage, starred: Bool,
                              withUndo: String,
                              onCompletion: ((_ isStarred: Bool, _ error: Error?) -> Void)?) {
        apiService.updateMessages(messageID: message.messsageID!.description,
                                  messagesIDIn: "",
                                  folder: message.folder!,
                                  starred: starred,
                                  read: false,
                                  updateFolder: false,
                                  updateStarred: true,
                                  updateRead: false,
                                  mailboxId: message.mailbox)
        { [weak self] (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success( _):
                    NotificationCenter.default.post(name: .updateInboxMessagesNotificationID,
                                                    object: true, userInfo: nil)
                    onCompletion?(starred, nil)
                case .failure(let error):
                    onCompletion?(starred, error)
                    self?.inboxViewerController?
                        .presenter?
                        .showAlert(withTitle: Strings.AppError.messagesError.localized,
                                   desc: error.localizedDescription,
                                   buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }
    
    func markMessagesAsSpam(lastSelectedMessage: EmailMessage,
                            withUndo: String) {
        // Banner Update
        inboxViewerController?.showBanner(withTitle: Strings.InboxViewer.Action.movingToSpam.localized,
                                          additionalConfigs: [.displayDuration(1.0),
                                                              .showButton(false)])
        // Update Last action
        inboxViewerController?
            .dataSource?
            .update(lastSelectedAction: .markAsSpam)

        var folder = lastSelectedMessage.folder ?? MessagesFoldersName.spam.rawValue
        
        if !withUndo.isEmpty {
            folder = MessagesFoldersName.spam.rawValue
        }
        
        // Moving tp folder
        moveMessageTo(message: lastSelectedMessage,
                      folder: folder,
                      withUndo: withUndo)
    }
    
    func moveMessagesToInbox(lastSelectedMessage: EmailMessage,
                             withUndo: String) {
        // Banner Update
        inboxViewerController?.showBanner(withTitle: Strings.InboxViewer.Action.movingToInbox.localized,
                                          additionalConfigs: [.displayDuration(1.0),
                                                              .showButton(false)])
        // Update Last action
        inboxViewerController?
            .dataSource?
            .update(lastSelectedAction: .moveToInbox)

        var folder = lastSelectedMessage.folder ?? MessagesFoldersName.inbox.rawValue
        
        if !withUndo.isEmpty {
            folder = MessagesFoldersName.inbox.rawValue
        }
        
        // Moving tp folder
        moveMessageTo(message: lastSelectedMessage,
                      folder: folder,
                      withUndo: withUndo)
    }
    
    func markMessagesAsArchived(lastSelectedMessage: EmailMessage,
                                withUndo: String) {
        // Banner Update
        inboxViewerController?.showBanner(withTitle: Strings.InboxViewer.Action.movingToArchive.localized,
                                          additionalConfigs: [.displayDuration(1.0),
                                                              .showButton(false)])
        // Update Last action
        inboxViewerController?
            .dataSource?
            .update(lastSelectedAction: .moveToArchive)

        var folder = lastSelectedMessage.folder ?? MessagesFoldersName.archive.rawValue
        
        if !withUndo.isEmpty {
            folder = MessagesFoldersName.archive.rawValue
        }
        
        // Moving tp folder
        moveMessageTo(message: lastSelectedMessage,
                      folder: folder,
                      withUndo: withUndo)
        
    }
    
    func markMessagesAsTrash(lastSelectedMessage: EmailMessage,
                             withUndo: String) {
        if SharedInboxState.shared.selectedMenu?.menuName == Menu.trash.menuName {
            deleteMessage(message: lastSelectedMessage)
        } else {
            inboxViewerController?.showBanner(withTitle: Strings.InboxViewer.Action.movingToTrash.localized,
                                              additionalConfigs: [.displayDuration(1.0),
                                                                  .showButton(false)])
            inboxViewerController?
                .dataSource?
                .update(lastSelectedAction: .moveToTrash)
            
            var folder = lastSelectedMessage.folder ?? MessagesFoldersName.trash.rawValue
            
            if !withUndo.isEmpty {
                folder = MessagesFoldersName.trash.rawValue
            }
            
            moveMessageTo(message: lastSelectedMessage,
                          folder: folder,
                          withUndo: withUndo)
        }
    }
    
    private func deleteMessage(message: EmailMessage) {
        Loader.start()
        apiService.deleteMessages(messagesIDIn: message.messsageID!.description) { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch(result) {
                case .success( _):
                    self?.inboxViewerController?
                        .dataSource?
                        .update(lastSelectedAction: .delete)
                    NotificationCenter.default.post(name: .updateInboxMessagesNotificationID, object: true, userInfo: nil)
                    self?.inboxViewerController?.router?.backToParent()
                case .failure(let error):
                    self?.inboxViewerController?.presenter?.showAlert(withTitle: Strings.AppError.error.localized,
                                                                      desc: error.localizedDescription,
                                                                      buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }
    
    private func moveMessageTo(message: EmailMessage,
                       folder: String,
                       withUndo: String) {
        guard let messageId = message.messsageID?.description else {
            return
        }
        
        apiService.updateMessages(messageID: messageId,
                                  messagesIDIn: "",
                                  folder: folder,
                                  starred: false,
                                  read: false,
                                  updateFolder: true,
                                  updateStarred: false,
                                  updateRead: false,
                                  mailboxId: message.mailbox)
        { [weak self] (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success( _):
                    NotificationCenter.default.post(name: .updateInboxMessagesNotificationID, object: true, userInfo: nil)
                    if !withUndo.isEmpty {
                        self?.inboxViewerController?.presenter?.showUndoToolbar(withText: withUndo)
                    }
                    self?.inboxViewerController?.router?.backToParent()
                case .failure(let error):
                    self?.inboxViewerController?
                        .presenter?
                        .showAlert(withTitle: Strings.AppError.error.localized,
                                   desc: error.localizedDescription,
                                   buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }

    func markAsRead(messageId: String, onCompletion: @escaping ((Bool) -> Void)) {
        apiService.updateMessages(messageID: "",
                                  messagesIDIn: messageId,
                                  folder: "",
                                  starred: false,
                                  read: true,
                                  updateFolder: false,
                                  updateStarred: false,
                                  updateRead: true) { (result) in
                                    DispatchQueue.main.async {
                                        switch(result) {
                                        case .success( _):
                                            onCompletion(true)
                                        case .failure(_):
                                            onCompletion(false)
                                        }
                                    }
        }
    }
    
    func toggleReadStatus(lastSelectedMessage: EmailMessage,
                          asRead: Bool,
                          withUndo: String,
                          bannerText: String = "",
                          shouldPop: Bool = false) {
        if !bannerText.isEmpty {
            inboxViewerController?.showBanner(withTitle: bannerText,
                                              additionalConfigs: [.displayDuration(1.0),
                                                                  .showButton(false)]
            )
        }
        
        apiService.updateMessages(messageID: "",
                                  messagesIDIn: lastSelectedMessage.messsageID?.description ?? "",
                                  folder: "",
                                  starred: false,
                                  read: asRead,
                                  updateFolder: false,
                                  updateStarred: false,
                                  updateRead: true,
                                  mailboxId: lastSelectedMessage.mailbox)
        { [weak self] (result) in
            DispatchQueue.main.async {
                guard let weakSelf = self else {
                    return
                }
                switch(result) {
                case .success( _):
                    weakSelf.inboxViewerController?
                        .dataSource?
                        .update(lastSelectedAction: .markAsRead)
                    weakSelf.inboxViewerController?
                        .viewInboxDelegate?
                        .didUpdateReadStatus(for: lastSelectedMessage, status: asRead)
                    
                    if !withUndo.isEmpty {
                        weakSelf.inboxViewerController?
                            .presenter?
                            .showUndoToolbar(withText: withUndo)
                    }
                    
                    if shouldPop {
                        weakSelf.inboxViewerController?
                            .router?
                            .backToParent()
                    }
                case .failure(let error):
                    DPrint("error:", error)
                    weakSelf.inboxViewerController?
                        .presenter?
                        .showAlert(withTitle: Strings.AppError.messagesError.localized,
                                   desc: error.localizedDescription,
                                   buttonTitle: Strings.Button.closeButton.localized
                    )
                }
            }
        }
    }
}

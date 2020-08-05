import Foundation
import UIKit
import Utility
import Inbox

final class InboxViewerPresenter {
    
    // MARK: Properties
    private (set) weak var viewController: InboxViewerController?
    private (set) var interactor: InboxViewerInteractor?
    private let pgpService = UtilityManager.shared.pgpService
    private var timer: Timer?
    private var counter = 0
    
    // MARK: - Constructor
    init(viewController: InboxViewerController, interactor: InboxViewerInteractor?) {
        self.viewController = viewController
        self.interactor = interactor
    }
    
    // MARK: - UI Setup
    func setupUI() {
        viewController?.undoToolbar.isHidden = true
        viewController?.generalToolbar.isHidden = false
        setupRightNavigationItems()
    }
    
    private func setupRightNavigationItems() {
        let moreItem = UIBarButtonItem(image: #imageLiteral(resourceName: "MoreButton"),
                                       style: .plain,
                                       target: self, action: #selector(onTapMore(_:)
            )
        )
        viewController?.navigationItem.rightBarButtonItem = moreItem
    }
    
    // MARK: - Helpers
    func fetchMessageDetails() {
        guard let messageId = viewController?.message?.messsageID else {
            return
        }
        interactor?.getMessage(messageID: messageId)
    }
    
    func markAsRead() {
        if viewController?.message?.read == false {
            toggleMessageStatus(shouldMarkAsRead: true, shouldPop: false)
        }
    }
    
    func showPreviewScreen(url: URL, encrypted: Bool) {
        if encrypted {
            guard let data = try? Data(contentsOf: url) else {
                DPrint("Attachment content data error!")
                showAlert(withTitle: Strings.AppError.attachmentErrorTitle.localized,
                          desc: Strings.AppError.attachmentErrorMessage.localized,
                          buttonTitle: Strings.Button.closeButton.localized)
                return
            }
            
            if let tempUrl = self.decryptAttachment(data: data) {
                viewController?.documentInteractionController.url = tempUrl
            } else {
                DPrint("Attachment decrypted content data error!")
                viewController?.documentInteractionController.url = url
            }
        } else {
            viewController?.documentInteractionController.url = url
        }
        
        viewController?
            .documentInteractionController
            .uti = url.typeIdentifier ?? "public.data, public.content"
        
        viewController?
            .documentInteractionController
            .name = url.localizedName ?? url.lastPathComponent
        
        DispatchQueue.main.async {
            self.viewController?.documentInteractionController.presentPreview(animated: true)
        }
        
        Loader.start()
    }
    
    private func decryptAttachment(data: Data) -> URL? {
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
    
    func showAlert(withTitle title: String, desc: String, buttonTitle: String) {
        viewController?.showAlert(with: title, message: desc, buttonTitle: buttonTitle)
    }
    
    func showUndoToolbar(withText undoText: String) {
        viewController?.undoToolbar.isHidden = false
        viewController?.generalToolbar.isHidden = true
        viewController?.undoItem.title = undoText
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(fadeUndoBar), userInfo: nil, repeats: true)
    }
    
    @objc
    private func fadeUndoBar() {
        counter +=  1
        
        let alpha = 1.0/Double(counter)
        viewController?.undoToolbar.alpha = CGFloat(alpha)
        
        if counter == undoActionDuration {
            hideUndoBar()
            viewController?
                .dataSource?
                .update(lastSelectedAction: nil)
        }
    }
    
    func hideUndoBar() {
        counter = 0
        timer?.invalidate()
        timer = nil
        viewController?.generalToolbar.isHidden = false
        viewController?.undoToolbar.alpha = 1.0
        viewController?.undoToolbar.isHidden = true
    }
    
    // MARK: - File Handlers
    func getFileUrlDocuments(withURLString: String) -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + (withURLString as NSString).lastPathComponent
        let url = URL(fileURLWithPath: path)
        return url
    }
    
    func checkIsFileExist(url: URL) -> Bool {
        let filePath = url.path
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Actions
    @objc
    private func onTapMore(_ sender: UIBarButtonItem) {
        var actions: [MoreAction] = []
        
        let readableAction: MoreAction = (viewController?.dataSource?.needReadAction() == true) ? .markAsUnread : .markAsRead

        if let menu = SharedInboxState.shared.selectedMenu as? Menu {
            switch menu {
            case .inbox, .sent:
                actions.append(readableAction)
                actions.append(.moveToArchive)
            case .archive:
                actions.append(readableAction)
                actions.append(.moveToInbox)
            case .spam:
                actions.append(.moveToArchive)
                actions.append(.moveToInbox)
            case .outbox,
                 .starred,
                 .trash:
                actions.append(readableAction)
                actions.append(.moveToArchive)
                actions.append(.moveToInbox)
            default:
                break
            }
            
            if menu != .spam {
                actions.append(.markAsSpam)
            }
        } else {
            actions = [.moveToInbox, .moveToArchive, readableAction]
        }
        
        actions.append(.moveTo)
        actions.append(.moveToTrash)
        actions.append(.cancel)

        let actionSheet = UIAlertController(title: Strings.Inbox.MoreAction.moreActions.localized,
                                            message: nil,
                                            preferredStyle: .actionSheet
        )
        
        for action in actions {
            let alertAction = UIAlertAction(title: action.localized,
                                            style: (action == .cancel) ?
                                                .cancel :
                                                (action == .moveToTrash) ?
                                                    .destructive :
                                                .default,
                                            handler: { [weak self] (_) in
                                                switch action {
                                                case .moveToInbox:
                                                    self?.moveToInbox()
                                                case .moveToArchive:
                                                    self?.moveToArchive()
                                                case .markAsRead, .markAsUnread:
                                                    self?.toggleMessageStatus(shouldPop: true)
                                                case .markAsSpam:
                                                    self?.markAsSpam()
                                                case .moveTo:
                                                    self?.onTapMoveTo()
                                                case .cancel:
                                                    actionSheet.dismiss(animated: true, completion: nil)
                                                default:
                                                    DPrint("Do Nothing")
                                                }
            })
            actionSheet.addAction(alertAction)
        }
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = sender
            popoverController.sourceView = viewController?.view
        }
        
        viewController?.present(actionSheet, animated: true, completion: nil)
    }
    
    func undo() {
        if let lastMessage = viewController?.dataSource?.lastAppliedActionMessage {
            viewController?.dataSource?.undo(lastMessage: lastMessage)
        }
    }
    
    private func moveToInbox() {
        if let lastMessage = viewController?.message {
            interactor?.moveMessagesToInbox(lastSelectedMessage: lastMessage,
                                            withUndo: Strings.Inbox.MoreAction.moveToInbox.localized)
        }
    }
    
    private func moveToArchive() {
        if let lastMessage = viewController?.message {
            interactor?.markMessagesAsArchived(lastSelectedMessage: lastMessage,
                                               withUndo: Strings.Inbox.MoreAction.moveToArchive.localized)
        }
    }
    
    private func toggleMessageStatus(shouldMarkAsRead: Bool? = nil, shouldPop: Bool = false) {
        if let lastSelectedMessage = viewController?.message {
            var readStatus = lastSelectedMessage.read ?? false
            
            var undoMessage = readStatus == true ?
                Strings.Inbox.UndoAction.undoMarkAsUnread.localized :
                Strings.Inbox.UndoAction.undoMarkAsRead.localized
            
            var bannerText = readStatus == true ?
                Strings.InboxViewer.Action.markingAsUnread.localized :
                Strings.InboxViewer.Action.markingAsRead.localized
            
            if let markAsRead = shouldMarkAsRead, markAsRead == true {
                readStatus = markAsRead
                undoMessage = ""
                bannerText = ""
            } else {
                readStatus = !readStatus
            }
            
            interactor?.toggleReadStatus(lastSelectedMessage: lastSelectedMessage,
                                         asRead: readStatus,
                                         withUndo: undoMessage,
                                         bannerText: bannerText,
                                         shouldPop: shouldPop
            )
        } else {
            DPrint("Messages are not selected")
        }
    }
    
    private func markAsSpam() {
        if let lastMessage = viewController?.message {
            interactor?.markMessagesAsSpam(lastSelectedMessage: lastMessage,
                                           withUndo: Strings.Inbox.MoreAction.markAsSpam.localized)
        }
    }
    
    private func onTapMoveTo() {
        if let messageId = viewController?.message?.messsageID, let user = viewController?.user {
            viewController?
                .router?
                .onTapMoveTo(withDelegate: viewController,
                             messageId: messageId,
                             user: user
            )
        }
    }
}

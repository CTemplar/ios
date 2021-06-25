import UIKit
import Utility
import Networking
import Inbox

class InboxViewerController: UIViewController, EmptyStateMachine {

    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var generalToolbar: UIToolbar!
    @IBOutlet weak var undoToolbar: UIToolbar!
    @IBOutlet weak var undoItem: UIBarButtonItem!
    @IBOutlet weak var replyAllButton: UIBarButtonItem!
    
    // MARK: Properties
    var documentInteractionController:UIDocumentInteractionController?
    private (set) var presenter: InboxViewerPresenter?
    private (set) var dataSource: InboxViewerDatasource?
    private (set) var router: InboxViewerRouter?
    private (set) var message: EmailMessage?
    private (set) weak var viewInboxDelegate: ViewInboxEmailDelegate?
    private (set) var user = UserMyself()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = []
        dataSource = InboxViewerDatasource(inboxViewerController: self, tableView: tableView, user: user)
        dataSource?.update(by: message)
        presenter?.setupUI()
        self.documentInteractionController = UIDocumentInteractionController()
       // self.documentInteractionController?.delegate = self
        // Fetch Message
        self.presenter?.fetchMessageDetails()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.prefersLargeTitle = false
        navigationController?.updateTintColor()
        
    }

    // MARK: - Setup
    func setup(message: EmailMessage?) {
        self.message = message
    }
    
    func setup(presenter: InboxViewerPresenter?) {
        self.presenter = presenter
    }
    
    func setup(router: InboxViewerRouter?) {
        self.router = router
    }
    
    func setup(delegate: ViewInboxEmailDelegate?) {
        self.viewInboxDelegate = delegate
    }
    
    func setup(user: UserMyself) {
        self.user = user
    }
    
    // MARK: - Actions
    @IBAction func onTapReply(_ sender: Any) {
//        var messageObject = message
//        if messageObject?.children?.isEmpty == false {
//            messageObject = messageObject?.children?.last
//        }
        router?.onTapReply(withMode: .reply, message: message)
    }
    
    @IBAction func onTapReplyAll(_ sender: Any) {
//        var messageObject = message
//        if messageObject?.children?.isEmpty == false {
//            messageObject = messageObject?.children?.last
//        }
        router?.onTapReplyAll(withMode: .replyAll, message: message)
    }
    
    @IBAction func onTapForward(_ sender: Any) {
//        var messageObject = message
//        if messageObject?.children?.isEmpty == false {
//            messageObject = messageObject?.children?.last
//        }
        router?.onTapForward(withMode: .forward, message: message)
    }
    
    @IBAction func onTapUndo(_ sender: Any) {
        presenter?.undo()
    }
}

// MARK: - MoveToViewControllerDelegate
extension InboxViewerController: MoveToViewControllerDelegate {
    func didMoveMessage(to folder: String) {
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] (timer1) in
            self?.view.makeToast("\(Strings.Inbox.messageMovedTo.localized) \(folder)",
                duration: 4,
                position: .bottom
            )
        }
    }
}

// MARK: - UIDocumentInteractionControllerDelegate
extension InboxViewerController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navigationViewController = self.navigationController else {
            return self
        }
        return navigationViewController
    }
    
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        Loader.stop()
       // controller = nil
    }
    
//    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
//        return self.view.frame
//    }
//
//    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
//        return self.view
//    }

    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tableView.reloadData()
    }

}

extension InboxViewerController: ViewInboxEmailDelegate {
    func didUpdateReadStatus(for message: EmailMessage, status: Bool) {
        if let menu = SharedInboxState.shared.selectedMenu {
            NotificationCenter.default.post(name: .updateMessagesReadCountNotificationID,
                                            object:
                [
                    "name": menu.menuName,
                    "isRead": status
                ]
            )
        }
    }
}

extension InboxViewerController: InboxPasswordProtectedEmailDelegate {
    func subjectDecrypt(password: String) {
        self.dataSource?.setupDataAfterPasswordDecryption(password: password)
    }
    
    func backToInbox() {
        self.navigationController?.popViewController(animated: true)
    }
   
}

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
    
    // MARK: Properties
    let documentInteractionController = UIDocumentInteractionController()
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
        dataSource = InboxViewerDatasource(inboxViewerController: self, tableView: tableView)
        dataSource?.update(by: message)
        presenter?.setupUI()
        presenter?.markAsRead()
        documentInteractionController.delegate = self
        
        navigationController?.prefersLargeTitle = false

        // Fetch Message
        self.presenter?.fetchMessageDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        router?.onTapReply(withMode: .reply, message: message)
    }
    
    @IBAction func onTapReplyAll(_ sender: Any) {
        router?.onTapReplyAll(withMode: .replyAll, message: message)
    }
    
    @IBAction func onTapForward(_ sender: Any) {
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

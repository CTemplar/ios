import UIKit
import SideMenu
import Networking
import Utility

class InboxViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noMessagePromptStackView: UIStackView! {
        didSet {
            noMessagePromptStackView.isHidden = false
        }
    }
    
    @IBOutlet weak var reloadButton: UIButton!
    
    @IBOutlet weak var messagesLabel: UILabel!
    
    @IBOutlet weak var unreadMessagesLabel: UILabel!
    
    @IBOutlet weak var generalToolbar: UIToolbar! {
        didSet {
            generalToolbar.isHidden = true
        }
    }
    
    @IBOutlet weak var draftToolbar: UIToolbar! {
        didSet {
            draftToolbar.isHidden = true
        }
    }
    
    @IBOutlet weak var selectionToolBar: UIToolbar! {
        didSet {
            selectionToolBar.isHidden = true
        }
    }
    
    @IBOutlet weak var undoToolBar: UIToolbar! {
        didSet {
            undoToolBar.isHidden = true
        }
    }
    
    @IBOutlet weak var inboxEmptyImageView: UIImageView!
    
    @IBOutlet weak var inboxEmptyLabel: UILabel!
    
    @IBOutlet weak var undoBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var composeButton: UIButton! {
        didSet {
            composeButton.layer.cornerRadius = composeButton.frame.size.height / 2
            composeButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var composeButtonBottomConstraintToSafeArea: NSLayoutConstraint! {
        didSet {
            composeButtonBottomConstraintToSafeArea.constant = 76.0
            composeButtonBottomConstraintToSafeArea.isActive = false
        }
    }
    
    @IBOutlet var composeButtonBottomConstraintToToolbar: NSLayoutConstraint! {
        didSet {
            composeButtonBottomConstraintToToolbar.constant = 0.0
            composeButtonBottomConstraintToSafeArea.isActive = true
        }
    }
    
    @IBOutlet var tableViewBottomConstraintToToolbar: NSLayoutConstraint! {
        didSet {
            tableViewBottomConstraintToToolbar.constant = 0.0
            tableViewBottomConstraintToToolbar.isActive = true
        }
    }
    
    @IBOutlet var tableViewBottomConstraintToSafeArea: NSLayoutConstraint! {
        didSet {
            tableViewBottomConstraintToSafeArea.constant = 94.0
            tableViewBottomConstraintToSafeArea.isActive = false
        }
    }
    
    // MARK: Properties
    private (set) var router: InboxRouter?
    private (set) var presenter: InboxPresenter?
    private (set) var dataSource: InboxDatasource?
    private var configurator: InboxConfigurator?
    private var runOnce = true
    
    // Callbacks
    var onTapSearch: ((UserMyself, UIViewController?) -> Void)?
    var onTapComposeWithDraft: ((AnswerMessageMode, EmailMessage, UserMyself, UIViewController?) -> Void)?
    var onTapCompose: ((AnswerMessageMode, UserMyself, UIViewController?) -> Void)?
    var onTapViewInbox: ((EmailMessage?, UserMyself?, ViewInboxEmailDelegate?, UIViewController?) -> Void)?
    var onTapMoveTo: ((MoveToViewControllerDelegate?, [Int], UserMyself, UIViewController?) -> Void)?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configurator = InboxConfigurator()
        configurator?.configure(inboxViewController: self,
                                onTapCompose: onTapCompose,
                                onTapComposeWithDraft: onTapComposeWithDraft,
                                onTapSearch: onTapSearch,
                                onTapViewInbox: onTapViewInbox,
                                onTapMoveTo: onTapMoveTo
        )

        dataSource = InboxDatasource(tableView: tableView, parentViewController: self, messages: [])
        
        presenter?.setupUI(emailsCount: 0, unreadEmails: 0, filterEnabled: false)
        
        setupLeftBarButtonItems()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reciveUpdateNotification(notification:)),
                                               name: .updateInboxMessagesNotificationID,
                                               object: nil
        )
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userSettingsUpdate),
                                               name: .updateUserSettingsNotificationID,
                                               object: nil
        )
        
        edgesForExtendedLayout = []
        
        // Fetch emails
        presenter?.interactor?.updateMessages(withUndo: "",
                                              silent: false,
                                              menu: SharedInboxState.shared.selectedMenu
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.prefersLargeTitle = true
        
        if runOnce == true {
            presenter?.interactor?.userMyself()
            runOnce = false
        }
        
        presenter?.updateNavigationBarTitle(basedOnMessageCount: dataSource?.selectedMessagesCount ?? 0,
                                            selectionMode: dataSource?.selectionMode ?? false,
                                            currentFolder: SharedInboxState.shared.selectedMenu ?? Menu.inbox
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Observers
    @objc
    private func reciveUpdateNotification(notification: Notification) {
        var silent = false
        
        if let silentMode = notification.object as? Bool {
            silent = silentMode
        }
        presenter?.interactor?.update(offset: 0)
        presenter?.interactor?.updateMessages(withUndo: "",
                                              silent: silent,
                                              menu: SharedInboxState.shared.selectedMenu)
        presenter?.interactor?.userMyself()
    }
    
    @objc
    private func userSettingsUpdate(notification: Notification) {
        presenter?.interactor?.userMyself()
    }
    
    // MARK: - Setup
    func update(menu: MenuConfigurable) {
        SharedInboxState.shared.update(menu: menu)
        SharedInboxState.shared.update(preferences: nil)
    }

    func setup(presenter: InboxPresenter) {
        self.presenter = presenter
    }
    
    func setup(router: InboxRouter) {
        self.router = router
    }
    
    func setup(dataSource: InboxDatasource) {
        self.dataSource = dataSource
    }
    
    // MARK: - UI
    func turnOnDraftToolBar() {
        [undoToolBar, draftToolbar]
            .forEach({
                $0?.isHidden = true
            })
        composeButton.isHidden = false
        draftToolbar.isHidden = false
        toggleGeneralToolbar(shouldShow: false)
    }
    
    func turnOnSelectionToolBar() {
        [draftToolbar, undoToolBar]
            .forEach({
                $0?.isHidden = true
            })
        composeButton.isHidden = true
        selectionToolBar.isHidden = false
        toggleGeneralToolbar(shouldShow: false)
    }
    
    func turnOnUndoToolbar() {
        [draftToolbar, selectionToolBar]
            .forEach({
                $0?.isHidden = true
            })
        composeButton.isHidden = false
        undoToolBar.isHidden = false
        toggleGeneralToolbar(shouldShow: false)
    }
    
    func toggleGeneralToolbar(shouldShow: Bool) {
        generalToolbar.isHidden = shouldShow == false
        if shouldShow {
            [draftToolbar,
             selectionToolBar,
             undoToolBar]
                .forEach({
                    $0?.isHidden = true
                })
            composeButtonBottomConstraintToToolbar.isActive = true
            composeButtonBottomConstraintToToolbar.constant = 16.0
            composeButtonBottomConstraintToSafeArea.isActive = false
            
            tableViewBottomConstraintToToolbar.isActive = true
            tableViewBottomConstraintToToolbar.constant = 0.0
            tableViewBottomConstraintToSafeArea.isActive = false
            
            composeButton.isHidden = false
        } else {
            composeButtonBottomConstraintToSafeArea.isActive = true
            composeButtonBottomConstraintToSafeArea.constant = 16.0
            composeButtonBottomConstraintToToolbar.isActive = false
            
            tableViewBottomConstraintToSafeArea.isActive = true
            tableViewBottomConstraintToSafeArea.constant = 0.0
            tableViewBottomConstraintToToolbar.isActive = false
        }
    }
    
    // MARK: - Actions
    @objc
    private func onTapMenu(_ sender: Any) {
        router?.showSidemenu()
    }
    
    @IBAction func onTapFilter(_ sender: UIBarButtonItem) {
        presenter?.showFilterView(from: sender)
    }
    
    @IBAction func onTapMore(_ sender: UIBarButtonItem) {
        presenter?.showMoreActions(from: sender)
    }
    
    @IBAction func onTapMoveTo(_ sender: UIBarButtonItem) {
        dataSource?.moveTo()
    }
    
    @IBAction func onTapSpam(_ sender: UIBarButtonItem) {
        dataSource?.moveMessagesToSpam()
    }
    
    @IBAction func onTapTrash(_ sender: UIBarButtonItem) {
        dataSource?.moveMessagesToTrash()
    }
    
    @IBAction func onTapUndo(_ sender: UIBarButtonItem) {
        presenter?.undo()
    }
    
    @IBAction func onTapCompose(_ sender: UIButton) {
        if let user = dataSource?.user {
            router?.showComposeViewController(answerMode: .newMessage, user: user)
        }
    }
}

extension InboxViewController: ViewInboxEmailDelegate {
    func didUpdateReadStatus(for message: EmailMessage, status: Bool) {
        dataSource?.updateMessageStatus(message: message, status: status)
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

// MARK: - LeftBarButtonItemConfigurable
extension InboxViewController: LeftBarButtonItemConfigurable {
    func setupLeftBarButtonItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(onTapMenu(_:)
            )
        )
    }
}

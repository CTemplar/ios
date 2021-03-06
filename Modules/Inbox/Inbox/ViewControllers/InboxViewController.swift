import UIKit
import SideMenu
import Networking
import Utility
import Combine

class InboxViewController: UIViewController, EmptyStateMachine {

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

    @IBOutlet weak var inboxEmptyImageView: UIImageView!
    
    @IBOutlet weak var inboxEmptyLabel: UILabel!
    
    @IBOutlet weak var undoButton: UIButton! {
        didSet {
            undoButton.isHidden = true
            undoButton.titleLabel?.font = .withType(.ExtraSmall(.Bold))
            undoButton.setTitle("Undo", for: .normal)
            undoButton.layer.cornerRadius = undoButton.frame.size.height / 2
            undoButton.applyDropShadow(shadowOpacity: 7.0,
                                       shadowColor: UIColor.black.withAlphaComponent(0.4),
                                       shadowRadius: 2.0,
                                       shadowOffset: .init(width: 0.0, height: 1.0))
        }
    }
    
    @IBOutlet weak var composeButton: UIButton! {
        didSet {
            composeButton.layer.cornerRadius = composeButton.frame.size.height / 2
            composeButton.applyDropShadow(shadowOpacity: 7.0,
                                          shadowColor: UIColor.black.withAlphaComponent(0.4),
                                          shadowRadius: 2.0,
                                          shadowOffset: .init(width: 0.0, height: 1.0))
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
    
    @Published var shouldEnableComposeButton = false
    var composeButtonCancellable: AnyCancellable?
    
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
        self.composeButtonCancellable = self.$shouldEnableComposeButton
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: self.composeButton)
        
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
                                               selector: #selector(reciveUpdateNotification(notification:)),
                                               name: .updateInboxMessagesNotificationID,
                                               object: nil
        )
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reciveUpdateNotification(notification:)),
                                               name: .newMessagesNotificationID,
                                               object: nil
        )
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userSettingsUpdate),
                                               name: .updateUserSettingsNotificationID,
                                               object: nil
        )
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveMailSentNotification(notification:)),
                                               name: .mailSentNotificationID,
                                               object: nil
        )

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveMailSentErrorNotification(notification:)),
                                               name: .mailSentErrorNotificationID,
                                               object: nil
        )

        edgesForExtendedLayout = []
        
        fetchMails()
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
        
        NotificationCenter.default.post(.init(name: .showForceAppUpdateAlertNotificationID))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            dataSource?.reload()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Fetch Data
    func fetchMails() {
        presenter?
            .interactor?
            .updateMessages(withUndo: "",
                            silent: false,
                            menu: SharedInboxState.shared.selectedMenu
        )
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
    private func receiveMailSentNotification(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let text = notification.object as? String ?? ""
            self.showBanner(withTitle: text,
                            additionalConfigs: [.displayDuration(2.0),
                                                .showButton(true)])
        }
    }
    
    @objc
    private func receiveMailSentErrorNotification(notification: Notification) {
        DispatchQueue.main.async {
            if let params = notification.object as? AlertKitParams {
                self.showAlert(with: params, onCompletion: {})
            }
        }
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
        [undoButton, draftToolbar]
            .forEach({
                $0?.isHidden = true
            })
        composeButton.isHidden = false
        draftToolbar.isHidden = false
        toggleGeneralToolbar(shouldShow: false)
    }
    
    func turnOnSelectionToolBar() {
        [draftToolbar, undoButton]
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
        undoButton.isHidden = false
        toggleGeneralToolbar(shouldShow: false)
    }
    
    func toggleGeneralToolbar(shouldShow: Bool) {
        generalToolbar.isHidden = shouldShow == false
        if shouldShow {
            [draftToolbar,
             selectionToolBar,
             undoButton]
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
// MARK: - InboxViewerPushable
extension InboxViewController: InboxViewerPushable {
    func openInboxViewer(of messageId: Int) {
        dataSource?.openInboxViewer(of: messageId)
    }
}

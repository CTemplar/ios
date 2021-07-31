import Foundation
import UIKit
import Utility
import Networking

public final class InboxSideMenuController: UIViewController {
    // MARK: Properties
    lazy var commonInboxVC: InboxViewController = {
        guard let vc: InboxViewController = UIStoryboard(name: "Inbox",
                                                    bundle: Bundle(for: type(of: self)))
            .instantiateViewController(withIdentifier: InboxViewController.className) as? InboxViewController else {
                fatalError("Inbox Storyboard couldn't found")
        }
        return vc
    }()

    private var currentParent: UIViewController?
    public private (set) var presenter: InboxSideMenuPresenter?
    private (set) var dataSource: InboxSideMenuDataSource?
    private (set) var router: InboxSideMenuRouter?
    private (set) weak var inbox: InboxViewController?
    private var configurator: InboxSideMenuConfigurator?
    
    public var onTapContacts: (([Contact], UserMyself) -> Void)?
    public var onTapSettings: ((UserMyself) -> Void)?
    public var onTapManageFolders: (([Folder], UserMyself) -> Void)?
    public var onTapFAQ: (() -> Void)?
    public var onTapMoveTo: ()
    public var onTapSubscriptions: ((UserMyself) -> Void)?

    // MARK: IBOutlets
    @IBOutlet weak var inboxSideMenuTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        setupNotifications()
        navigationController?.navigationBar.isHidden = true
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .background).async {
            self.presenter?.interactor?.unreadMessagesCounter()
        }
    }
    
    deinit {
        removeAllNotifications()
    }
    
    // MARK: - Configuration
    private func configuration() {
        configurator = InboxSideMenuConfigurator()
        configurator?.configure(viewController: self,
                                onTapContacts: onTapContacts,
                                onTapSettings: onTapSettings,
                                onTapManageFolders: onTapManageFolders,
                                onTapFAQ: onTapFAQ, onTapSubscriptions: onTapSubscriptions
        )
        dataSource?.setup(parent: self)
        dataSource?.setup(tableView: inboxSideMenuTableView)
    }
    
    private func reset() {
        configurator = nil
        dataSource = nil
        removeAllNotifications()
    }
    
    private func removeAllNotifications() {
        NotificationCenter.default.removeObserver(self, name: .updateUserDataNotificationID, object: nil)
        NotificationCenter.default.removeObserver(self, name: .updateCustomFolderNotificationID, object: nil)
        NotificationCenter.default.removeObserver(self, name: .updateMessagesReadCountNotificationID, object: nil)
        NotificationCenter.default.removeObserver(self, name: .reloadViewControllerNotificationID, object: nil)
    }

    // MARK: - Setup
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(userDataUpdate), name: .updateUserDataNotificationID, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(customFoldersUpdated(notification:)), name: .updateCustomFolderNotificationID, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUnreadMessageCount(notification:)), name: .updateMessagesReadCountNotificationID, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSideMenu), name: .reloadViewControllerNotificationID, object: nil)
    }
    
    func setup(inboxVC: InboxViewController) {
        self.inbox = inboxVC
    }
    
    func setup(parent: UIViewController) {
        self.currentParent = parent
    }
    
    func setup(presenter: InboxSideMenuPresenter) {
        self.presenter = presenter
    }
    
    func setup(router: InboxSideMenuRouter) {
        self.router = router
    }
    
    func setup(dataSource: InboxSideMenuDataSource) {
        self.dataSource = dataSource
    }
    
    public func resetToInbox() {
        self.dataSource?.didSelect(menu: .inbox)
    }
    
    public func setup(onTapContacts: (([Contact], UserMyself) -> Void)?,
               onTapSettings: ((UserMyself) -> Void)?,
               onTapManageFolders: (([Folder], UserMyself) -> Void)?,
               onTapFAQ: (() -> Void)?,onTapSubscriptions: ((UserMyself) -> Void)?) {
        self.onTapContacts = onTapContacts
        self.onTapSettings = onTapSettings
        self.onTapManageFolders = onTapManageFolders
        self.onTapFAQ = onTapFAQ
        self.onTapSubscriptions = onTapSubscriptions
    }
    
    // MARK: - Observers
    @objc
    private func userDataUpdate(notification: Notification) {
        guard let userData = notification.object as? UserMyself else {
            return
        }
            
        if let folders = userData.foldersList {
            dataSource?.update(customFolders: folders)
            dataSource?.reload()
        }
        
        let userName = userData.username == nil ? "" : (userData.username ?? "")

        if let mailboxes = userData.mailboxesList {
            presenter?.setupUserProfileBar(mailboxes: mailboxes, userName: userName)
        }
        
        presenter?.viewController?.inbox?.dataSource?.update(user: userData)
        
        DispatchQueue.main.async {
            self.presenter?.interactor?.unreadMessagesCounter()
        }
    }
    
    @objc
    private func customFoldersUpdated(notification: Notification) {
        let customFolders = notification.object as? [Folder] ?? []
        dataSource?.update(customFolders: customFolders)
        dataSource?.reload()
    }
    
    @objc
    private func reloadSideMenu() {
        reset()
        configuration()
        setupNotifications()
    }
    
    @objc
    private func updateUnreadMessageCount(notification: Notification) {
        if let folder = notification.object as? [String: Any] {
            let folderName = folder["name"] as? String ?? ""
            let isRead = folder["isRead"] as? Bool ?? false
            var unreadCounters = dataSource?.unreadMessages ?? []
            for i in 0..<unreadCounters.count {
                if unreadCounters[i].folderName == folderName {
                    if isRead {
                        var count = ((unreadCounters[i].unreadMessagesCount ?? 1) - 1)
                        count = count < 0 ? 0 : count
                        unreadCounters[i].unreadMessagesCount = count
                    } else {
                        unreadCounters[i].unreadMessagesCount = ((unreadCounters[i].unreadMessagesCount ?? 0) + 1)
                    }
                    
                    if let folderType = Menu(rawValue: folderName) {
                        presenter?.interactor?.setUnreadCounters(unreadCounters, folder: folderType)
                    }
                }
            }
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.inboxSideMenuTableView.reloadData()
    }
}

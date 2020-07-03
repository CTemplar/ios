import Foundation
import UIKit
import Utility
import Networking

final class InboxSideMenuController: UIViewController {
    // MARK: Properties
    lazy var draft: InboxViewController = {
        let draftVC: InboxViewController = UIStoryboard(storyboard: .inbox,
                                                        bundle: Bundle(for: type(of: self)
            )
        ).instantiateViewController()
        draftVC.update(menu: .draft)
        return draftVC
    }()
    
    
    lazy var sent: InboxViewController = {
        let sentVC: InboxViewController = UIStoryboard(storyboard: .inbox,
                                                       bundle: Bundle(for: type(of: self)
            )
        ).instantiateViewController()
        sentVC.update(menu: .sent)
        return sentVC
    }()
    
    lazy var outbox: InboxViewController = {
        let outboxVC: InboxViewController = UIStoryboard(storyboard: .inbox,
                                                         bundle: Bundle(for: type(of: self)
            )
        ).instantiateViewController()
        outboxVC.update(menu: .outbox)
        return outboxVC
    }()
    
    lazy var starred: InboxViewController = {
        let starredVC: InboxViewController = UIStoryboard(storyboard: .inbox,
                                                         bundle: Bundle(for: type(of: self)
            )
        ).instantiateViewController()
        starredVC.update(menu: .starred)
        return starredVC
    }()

    lazy var archive: InboxViewController = {
        let archiveVC: InboxViewController = UIStoryboard(storyboard: .inbox,
                                                         bundle: Bundle(for: type(of: self)
            )
        ).instantiateViewController()
        archiveVC.update(menu: .archive)
        return archiveVC
    }()
    
    lazy var spam: InboxViewController = {
        let spamVC: InboxViewController = UIStoryboard(storyboard: .inbox,
                                                         bundle: Bundle(for: type(of: self)
            )
        ).instantiateViewController()
        spamVC.update(menu: .spam)
        return spamVC
    }()
    
    lazy var trash: InboxViewController = {
        let trashVC: InboxViewController = UIStoryboard(storyboard: .inbox,
                                                         bundle: Bundle(for: type(of: self)
            )
        ).instantiateViewController()
        trashVC.update(menu: .trash)
        return trashVC
    }()
    
    lazy var allMail: InboxViewController = {
        let allMailVC: InboxViewController = UIStoryboard(storyboard: .inbox,
                                                         bundle: Bundle(for: type(of: self)
            )
        ).instantiateViewController()
        allMailVC.update(menu: .allMails)
        return allMailVC
    }()
    
    lazy var customFolder: InboxViewController = {
        let customFolderVC: InboxViewController = UIStoryboard(storyboard: .inbox,
                                                         bundle: Bundle(for: type(of: self)
            )
        ).instantiateViewController()
        return customFolderVC
    }()
    
    private var currentParent: UIViewController?
    private (set) var presenter: InboxSideMenuPresenter?
    private (set) var dataSource: InboxSideMenuDataSource?
    private (set) var router: InboxSideMenuRouter?
    private (set) weak var inbox: InboxViewController?
    private var configurator: InboxSideMenuConfigurator?
    
    var onTapContacts: (() -> Void) = {}
    var onTapSettings: (() -> Void) = {}
    var onTapManagerFolders: (() -> Void) = {}
    var onTapFAQ: (() -> Void) = {}

    // MARK: IBOutlets
    @IBOutlet weak var inboxSideMenuTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var triangle: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        setupNotifications()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
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
                                onTapManagerFolders: onTapManagerFolders,
                                onTapFAQ: onTapFAQ)
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
        
        if (Device.IS_IPAD) {
            NotificationCenter.default.addObserver(self, selector: #selector(reloadSideMenu), name: .reloadViewControllerNotificationID, object: nil)
        }
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
    
    func setup(onTapContacts: @escaping (() -> Void),
               onTapSettings: @escaping (() -> Void),
               onTapManagerFolders: @escaping (() -> Void),
               onTapFAQ: @escaping (() -> Void)) {
        self.onTapContacts = onTapContacts
        self.onTapSettings = onTapSettings
        self.onTapManagerFolders = onTapManagerFolders
        self.onTapFAQ = onTapFAQ
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
                        unreadCounters[i].unreadMessagesCount = ((unreadCounters[i].unreadMessagesCount ?? 1) - 1)
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
}

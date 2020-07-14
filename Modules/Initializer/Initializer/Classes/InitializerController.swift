import UIKit
import Foundation
import Utility
import Networking
import Login
import SideMenu
import Inbox
import GlobalSearch

public class InitializerController: UIViewController, HashingService {
    
    // MARK: Properties
    private let apiService = NetworkManager.shared.apiService
    
    private let inboxCoordinator = InboxCoordinator()
    
    lazy private var keyChainService: KeychainService = {
        return UtilityManager.shared.keychainService
    }()
    
    lazy private var isRememberMeEnabled: Bool = {
        return keyChainService.getRememberMeValue()
    }()
    
    lazy private var twoFAstatus: Bool = {
        return keyChainService.getTwoFAstatus()
    }()
    
    private var messageId = -1
    public var onTapComposeWithDraft: ((AnswerMessageMode, EmailMessage, UserMyself, UIViewController?) -> Void)?
    public var onTapCompose: ((AnswerMessageMode, UserMyself, UIViewController?) -> Void)?
    public var onTapViewInbox: ((EmailMessage, String, UserMyself, ViewInboxEmailDelegate?) -> Void)?
    public var onTapContacts: (([Contact], Bool, UIViewController?) -> Void)?
    public var onTapSettings: ((UserMyself, UIViewController?) -> Void)?
    public var onTapManageFolders: (([Folder], UserMyself, UIViewController?) -> Void)?
    public var onTapFAQ: ((UIViewController?) -> Void)?
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (isRememberMeEnabled && apiService.canTokenRefresh()) || apiService.isTokenValid() {
            moveToNext()
        } else if isRememberMeEnabled && !twoFAstatus {
            let username = keyChainService.getUserName()
            let password = keyChainService.getPassword()
            authenticateUser(with: username, and: password, with: "")
        } else {
            showLoginViewController()
        }
    }
    
    // MARK: - Navigation Logics
    func moveToNext() {
        showInboxNavigationController()
    }
    
    func showLoginViewController() {
        DPrint("show login VC")
        DispatchQueue.main.async {
            let loginCoordinator = LoginCoordinator()
            loginCoordinator.showLogin(from: self) { [weak self] in
                self?.showInboxNavigationController()
            }
        }
    }
    
    func showInboxNavigationController() {
        DispatchQueue.main.async {
            let sideMenu = self.sideMenu()
            sideMenu.modalPresentationStyle = .fullScreen
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.setRootViewController(sideMenu, options: .init(direction: .toRight, style: .easeInOut))
            }
        }
    }
    
    // MARK: - Push Handler
    public func update(messageId: Int) {
        inboxCoordinator.update(messageId: messageId)
    }
}

// MARK: - SlideMenu Setup
extension InitializerController {
    func sideMenu() -> SideMenuController {
        let response = inboxCoordinator.showInbox(onTapCompose: onTapCompose,
                                                  onTapComposeWithDraft: onTapComposeWithDraft,
                                                  onTapSearch:
            { (_, user, presenter) in
                let searchCoordinator = GlobalSearchCoordinator()
                searchCoordinator.showSearch(from: presenter,
                                             withUser: user)
                { [weak self] (message, user) in
                    self?.onTapViewInbox?(message,
                                          SharedInboxState.shared.selectedMenu?.menuName ?? "",
                                          user,
                                          presenter as? ViewInboxEmailDelegate
                    )
                }
        }, onTapViewInbox: onTapViewInbox,
           onTapContacts: onTapContacts,
           onTapSettings: onTapSettings,
           onTapManageFolders: onTapManageFolders,
           onTapFAQ: onTapFAQ
        )
        
        let sideMenuController = SideMenuController(contentViewController: response.content, menuViewController: response.menu)
        return sideMenuController
    }
}

// MARK: - Authentication
extension InitializerController {
    func authenticateUser(with username: String, and password: String, with twoFACode: String) {
        Loader.start()
        generateHashedPassword(for: username, password: password) { (result) in
            guard let value = try? result.get() else {
                Loader.stop()
                self.showLoginViewController()
                return
            }
            NetworkManager.shared.networkService.loginUser(with: LoginDetails(userName: username,
                                                                              password: value,
                                                                              twoFACode: twoFACode)
            ) { (result) in
                Loader.stop()
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        if let token = value.token {
                            UtilityManager.shared.keychainService.saveToken(token: token)
                            self.moveToNext()
                        }else {
                            self.showLoginViewController()
                        }
                    case .failure(_):
                        self.showLoginViewController()
                    }
                }
            }
        }
    }
}

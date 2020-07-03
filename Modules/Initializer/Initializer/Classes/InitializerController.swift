import UIKit
import Foundation
import Utility
import Networking
import Login
import SideMenu

public class InitializerController: UIViewController, HashingService {

    // MARK: Properties
    private let apiService = NetworkManager.shared.apiService
    
    lazy private var keyChainService: KeychainService = {
        return UtilityManager.shared.keychainService
    }()
    
    lazy private var isRememberMeEnabled: Bool = {
        return keyChainService.getRememberMeValue()
    }()
    
    lazy private var twoFAstatus: Bool = {
        return keyChainService.getTwoFAstatus()
    }()

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (isRememberMeEnabled && apiService.canTokenRefresh()) || apiService.isTokenValid() {
            moveToNext()
        } else if isRememberMeEnabled && !twoFAstatus {
            let username = keyChainService.getUserName()
            let password = keyChainService.getPassword()
            authenticateUser(with: username, and: password)
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
//            let loginCoordinator = LoginCoordinator()
//            loginCoordinator.showLogin(from: self, withSideMenu: self.sideMenu())
        }
    }
    
    func showInboxNavigationController() {
        DispatchQueue.main.async {
//            let sideMenu = self.sideMenu()
//            sideMenu.modalPresentationStyle = .fullScreen
//            if let window = UIApplication.shared.getKeyWindow() {
//                window.setRootViewController(sideMenu)
//            } else {
//                self.show(sideMenu, sender: self)
//            }
        }
    }
}

// MARK: - SlideMenu Setup
extension InitializerController {
//    func sideMenu() -> SideMenuController {
//        let inboxViewController = InboxViewController.instantiate(fromAppStoryboard: .Inbox)
//        inboxViewController.messageID = messageId
//
//        let inboxNavigationController = UIViewController.getNavController(rootViewController: inboxViewController)
//
//        let leftMenuController = InboxSideMenuViewController.instantiate(fromAppStoryboard: .InboxSideMenu)
//        leftMenuController.inboxViewController = inboxViewController
//        leftMenuController.dataSource?.selectedIndexPath = IndexPath(row: 0, section: SideMenuSectionIndex.mainFolders.rawValue)
//
//        let sideMenuController = SideMenuController(contentViewController: inboxNavigationController, menuViewController: leftMenuController)
//
//        return sideMenuController
//    }
}

// MARK: - Authentication
extension InitializerController {
    func authenticateUser(with username: String, and password: String) {
        Loader.start()
        generateHashedPassword(for: username, password: password) { (result) in
            guard let value = try? result.get() else {
                Loader.stop()
                self.showLoginViewController()
                return
            }
            NetworkManager.shared.networkService.loginUser(with: LoginDetails(userName: username, password: value)) { (result) in
                Loader.stop()
                switch result {
                case .success(let value):
                    if let token = value.token {
                        UtilityManager.shared.keychainService.saveToken(token: token)
                        self.moveToNext()
                    }else {
                        self.showLoginViewController()
                    }
                    break
                case .failure(_):
                    self.showLoginViewController()
                    break
                }
            }
        }
    }
}

import UIKit
import Foundation
import Utility
import Networking
import Login
import SideMenu
import Inbox
import InboxViewer
import GlobalSearch
import AppSettings
import Compose

public class InitializerController: UIViewController, HashingService, EmptyStateMachine {
    
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
    public var onTapCompose: ((AnswerMessageMode, UserMyself, EmailMessage?, UIViewController?) -> Void)?
    public var onTapContacts: (([Contact], Bool, UIViewController?) -> Void)?
    public var onTapFAQ: ((UIViewController?) -> Void)?
    private var globalSearchCoordinator: GlobalSearchCoordinator?
    private var sideMenuResponse: (menu: InboxSideMenuController, content: UIViewController)?
    private var sideMenuVC: SideMenuController?
    
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
            if let sideMenu = self.sideMenu() {
                sideMenu.modalPresentationStyle = .fullScreen
                if let keyWindow = UIApplication.shared.windows.first {
                    keyWindow.setRootViewController(sideMenu, options: .init(direction: .toRight, style: .easeInOut))
                }
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
    func sideMenu() -> SideMenuController? {
        sideMenuResponse = inboxCoordinator.showInbox(onTapCompose: { (mode, user, presenter) in
            self.showCompose(withMode: mode, message: nil, user: user, presenter: presenter)
        }, onTapComposeWithDraft: { (mode, message, user, presenter) in
            self.showCompose(withMode: mode, message: message, user: user, presenter: presenter)
        }, onTapSearch: { (user, presenter) in
            self.openSearch(from: presenter, user: user)
        }, onTapViewInbox: { (message, user, delegate, presenter) in
            self.openInboxViewer(withMessage: message,
                                 user: user,
                                 delegate: delegate,
                                 presenter: presenter)
        }, onTapContacts: { (contacts, toggle, presenter) in
            self.onTapContacts?(contacts, toggle, presenter)
        }, onTapSettings: { (user, presenter) in
            self.openSettings(withUser: user, presenter: presenter)
        }) { (presenter) in
            self.onTapFAQ?(presenter)
        }
        
        sideMenuVC = SideMenuController(contentViewController: sideMenuResponse?.content ?? UIViewController(),
                                                    menuViewController: sideMenuResponse?.menu ?? UIViewController())
        return sideMenuVC
    }
    
    private func openSearch(from presenter: UIViewController?, user: UserMyself) {
        globalSearchCoordinator = GlobalSearchCoordinator()
        globalSearchCoordinator?.showSearch(from: presenter,
                                            withUser: user) { [weak self] (message, user, delegate, searchController) in
                                                self?.openInboxViewer(withMessage: message,
                                                              user: user,
                                                              delegate: delegate,
                                                              presenter: searchController)
        }
    }
    
    private func openSettings(withUser user: UserMyself, presenter: UIViewController?) {
        let settingsCoordinator = AppSettingsCoordinator()
        settingsCoordinator.showSettings(withUser: user, presenter: presenter)
    }
    
    private func openInboxViewer(withMessage message: EmailMessage?,
                                 user: UserMyself?,
                                 delegate: ViewInboxEmailDelegate?,
                                 presenter: UIViewController?) {
        let inboxViewerCoordinator = InboxViewerCoordinator()
        inboxViewerCoordinator
            .showInboxViewer(withUser: user,
                             message: message,
                             onReply: { [weak self] (mode, message, presenter) in
                                self?.showCompose(withMode: mode,
                                                  message: message,
                                                  user: user,
                                                  presenter: presenter)
                }, onForward: { [weak self] (mode, message, presenter) in
                    self?.showCompose(withMode: mode,
                                      message: message,
                                      user: user,
                                      presenter: presenter)
                }, onReplyAll: { [weak self] (mode, message, presenter) in
                    self?.showCompose(withMode: mode,
                                      message: message,
                                      user: user,
                                      presenter: presenter)
                }, onMoveTo: { [weak self] (delegate, messageId, user, presenter) in
                    self?.inboxCoordinator.showMoveToController(withMoveToDelegate: delegate,
                                                                selectedMessageIds: [messageId],
                                                                user: user,
                                                                presenter: presenter
                    )
            }, viewInboxDelegate: delegate,
               presenter: presenter
        )
    }
    
    private func showCompose(withMode mode: AnswerMessageMode,
                             message: EmailMessage?,
                             user: UserMyself?,
                             presenter: UIViewController?) {
        if let user = user {
            let composeCoordinator = ComposeCoordinator()

            if let email = message, email.attachments?.isEmpty == false {
                
                let alertController = UIAlertController(title: Strings.Compose.SelectDraftOption.localized,
                                                        message: nil, preferredStyle: .actionSheet)
                
                alertController.addAction(.init(title: Strings.Compose.includeAttachments.localized,
                                                style: .default, handler:
                    { (_) in
                        composeCoordinator.showCompose(from: presenter,
                                                       withUser: user,
                                                       existingEmail: message,
                                                       answerMode: mode,
                                                       includeAttachments: true)
                }))
                
                alertController.addAction(.init(title: Strings.Compose.dontIncludeAttachments.localized,
                                                style: .default, handler:
                    { (_) in
                        composeCoordinator.showCompose(from: presenter,
                                                       withUser: user,
                                                       existingEmail: message,
                                                       answerMode: mode,
                                                       includeAttachments: false)
                }))
                
                alertController.addAction(.init(title: Strings.Button.cancelButton.localized,
                                                style: .cancel,
                                                handler:
                    { (_) in
                        alertController.dismiss(animated: true, completion: nil)
                }))
                
                presenter?.present(alertController, animated: true, completion: nil)
                
            } else {
                composeCoordinator.showCompose(from: presenter,
                                               withUser: user,
                                               existingEmail: message,
                                               answerMode: mode,
                                               includeAttachments: false)
            }
        }
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

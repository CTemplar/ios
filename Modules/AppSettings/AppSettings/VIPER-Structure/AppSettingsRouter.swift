import UIKit
import Foundation
import Utility
import Networking
import Inbox

final class AppSettingsRouter {
    // MARK: Properties
    private (set) weak var parentController: AppSettingsController?
    
    // MARK: - Constructor
    init(parentController: AppSettingsController?) {
        self.parentController = parentController
    }
    
    // MARK: - Routing Helpers
    func onTapMenu() {
        parentController?.sideMenuController?.revealMenu()
    }
    
    func onTapNotification() {
        UIApplication.openAppSettings()
    }

    func onTapDashboard() {
        let dashboard: DashboardTableViewController = UIStoryboard(storyboard: .dashboard,
                                                                   bundle: Bundle(for: DashboardTableViewController.self)
        ).instantiateViewController()
        
        let configurator = DashboardConfigurator()
        configurator.configure(viewController: dashboard,
                               user: parentController?.user ?? UserMyself())
        parentController?.show(dashboard, sender: parentController)

    }
    
    func onTapWhiteBlackList() {
        let whiteBlackList: WhiteBlackListsViewController = UIStoryboard(storyboard: .whiteBlackLists,
                                                                         bundle: Bundle(for: WhiteBlackListsViewController.self)
        ).instantiateViewController()
        whiteBlackList.setup(user: parentController?.user ?? UserMyself())
        parentController?.show(whiteBlackList, sender: parentController)
    }
    
    func onTapFilter() {
        let filterList: FilterVC = UIStoryboard(storyboard: .filter,
                                                                         bundle: Bundle(for: FilterVC.self)
        ).instantiateViewController()
        
        parentController?.show(filterList, sender: parentController)
    }
    func onTapComposer() {
        let composerVC: ComposeVC = UIStoryboard(storyboard: .composer,
                                                                         bundle: Bundle(for: ComposeVC.self)
        ).instantiateViewController()
        composerVC.user = self.parentController?.datasource?.user ?? UserMyself()
        parentController?.show(composerVC, sender: parentController)
    }
    func onTapLanguage() {
        let languageSelector: SelectLanguageViewController = UIStoryboard(storyboard: .language,
                                                                          bundle: Bundle(for: SelectLanguageViewController.self)
        ).instantiateViewController()
        parentController?.show(languageSelector, sender: self)
    }
    
    func onTapEncryption() {
        let encryptionController: EncryptionController = UIStoryboard(storyboard: .encryption,
                                                                      bundle: Bundle(for: EncryptionController.self)
        ).instantiateViewController()
        
        encryptionController.setup(user: parentController?.user ?? UserMyself())
        
        let embeddedNav = UINavigationController.getNavController(rootViewController: encryptionController)
        
        embeddedNav.modalPresentationStyle = .formSheet
        
        parentController?.present(embeddedNav, animated: true, completion: nil)
    }
    
    func onTapSignature(with type: SignatureType) {
        let signatureController: SignatureViewController = UIStoryboard(storyboard: .signature,
                                                                        bundle: Bundle(for: SignatureViewController.self)
        ).instantiateViewController()

        signatureController.setup(user: parentController?.user ?? UserMyself())
        signatureController.setup(signatureType: type)
        parentController?.show(signatureController, sender: self)
    }
    
    func onTapKeys() {
        let pgpKeyViewController: PGPKeysViewController = UIStoryboard(storyboard: .key,
                                                                       bundle: Bundle(for: PGPKeysViewController.self)
        ).instantiateViewController()

        parentController?.show(pgpKeyViewController, sender: self)
    }
    
    func onTapAddress() {
        let aliasViewController: AliasController = UIStoryboard(storyboard: .address,
                                                                       bundle: Bundle(for: AliasController.self)
        ).instantiateViewController()

        parentController?.show(aliasViewController, sender: self)
    }
    
    func onTapManageFolders() {
        guard let user = parentController?.user else {
            return
        }
        
        let inboxCoordinator = InboxCoordinator()
        inboxCoordinator.openManageFolders(withFolders: user.foldersList ?? [],
                                           user: user,
                                           from: parentController,
                                           fromSideMenu: false)
    }
    
    func onTapLogOut() {
        let params = AlertKitParams(
            title: Strings.Logout.logoutTitle.localized,
            message: Strings.Logout.logoutMessage.localized,
            cancelButton: Strings.Button.cancelButton.localized,
            otherButtons: [
                Strings.Button.logoutButton.localized
            ]
        )
        
        parentController?.showAlert(with: params, onCompletion: { [weak self] (index) in
            switch index {
            case 0:
                DPrint("Cancel Logout")
            default:
                DPrint("Logout")
                (self?.parentController?
                    .sideMenuController?
                    .menuViewController as? InboxSideMenuController)?
                    .presenter?
                    .interactor?
                    .logOut()
            }
        })
    }
    
    func logoutAction() {
        UtilityManager.shared.keychainService.deleteUserCredentialsAndToken()
        UtilityManager.shared.pgpService.deleteStoredPGPKeys()
        UIApplication.shared.applicationIconBadgeNumber = 0
        NotificationCenter.default.post(name: .logoutCompleteNotificationID, object: nil)
    }
}

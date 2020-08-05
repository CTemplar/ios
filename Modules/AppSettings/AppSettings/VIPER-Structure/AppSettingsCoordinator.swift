import Foundation
import Networking
import Utility
import Inbox
import UIKit

public final class AppSettingsCoordinator {
    // MARK: Properties
    private (set) var settingsController: AppSettingsController?
    
    // MARK: - Constructor
    public init() {}
    
    // MARK: - Navigation
    public func showSettings(withUser user: UserMyself, presenter: UIViewController?) {
        let settingsVC: AppSettingsController = UIStoryboard(storyboard: .settings,
                                                             bundle: Bundle(for: AppSettingsController.self)
        ).instantiateViewController()

        let configurator = AppSettingsConfigurator()
        configurator.configure(with: settingsVC, user: user)
        
        let navController = InboxNavigationController(rootViewController: settingsVC)
        navController.prefersLargeTitle = true
        presenter?
            .sideMenuController?
            .setContentViewController(to: navController, animated: true, completion: {
                presenter?.sideMenuController?.hideMenu()
        })
    }
}

import Foundation
import UIKit
import Utility
import Inbox
import Networking

public final class AppContactsCoordinator {
    // MARK: Properties
    private var appContactsController: AppContactsViewController?
    
    // MARK: - Constructor
    public init() {}
    
    public func showContactScreen(from viewController: UIViewController?,
                                  user: UserMyself,
                                  onCreateNewEmail: @escaping ((_ emailId: String, _ fromVC: UIViewController?) -> Void)) {
        
        appContactsController = UIStoryboard(storyboard: .contacts,
                                             bundle: Bundle(for: AppContactsCoordinator.self)
        ).instantiateViewController()
        
        let viewModel = AppContactsViewModel(user: user)

        appContactsController?.configure(with: viewModel)
        
        appContactsController?.onComposeEmail = { (emailId, vc) in
            onCreateNewEmail(emailId, vc)
        }
        
        let navController = InboxNavigationController(rootViewController: appContactsController!)
        navController.prefersLargeTitle = true
        viewController?
            .sideMenuController?
            .setContentViewController(to: navController, animated: true, completion: {
                viewController?.sideMenuController?.hideMenu()
        })
    }
}

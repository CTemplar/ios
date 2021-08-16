//
//  AppSubscriptionsCoordinator.swift
//  AppSettings
//


import UIKit
import Networking
import Utility

public final class AppSubscriptionsCoordinator {
    // MARK: Properties
    private (set) var subscriptionController: AppSubscriptionsCoordinator?
    
    // MARK: - Constructor
    public init() {}
    
    // MARK: - Navigation
    public func showSubscriptions(withUser user: UserMyself, presenter: UIViewController?) {
        let controller: SubscriptionListController = UIStoryboard(storyboard: .subscribe,
                                                             bundle: Bundle(for: AppSubscriptionsCoordinator.self)
        ).instantiateViewController()
        
        let configurator = SubscribeConfigurator()
        configurator.configure(with: controller, user: user)
        
        
        let navController = InboxNavigationController(rootViewController: controller)
        navController.prefersLargeTitle = true
        presenter?
            .sideMenuController?
            .setContentViewController(to: navController, animated: true, completion: {
                presenter?.sideMenuController?.hideMenu()
        })
    }
}

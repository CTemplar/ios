import Foundation
import Utility
import Networking
import UIKit
import Inbox

public final class GlobalSearchCoordinator {
    // MARK: Properties
    private var searchController: GlobalSearchViewController?
    
    // MARK: - Constructor
    public init() {}
    
    public func showSearch(from viewController: UIViewController?,
                           withUser user: UserMyself,
                           onTapMessage: @escaping ((EmailMessage, UserMyself, ViewInboxEmailDelegate?, UIViewController?) -> Void)) {
        searchController = UIStoryboard(storyboard: .search,
            bundle: Bundle(for: GlobalSearchViewController.self)).instantiateViewController()
        
        let configurator = GlobalSearchConfigurator()
        configurator.configure(withSearchController: searchController!,
                               user: user) { [weak self] (message, user, delegate) in
                                onTapMessage(message, user, delegate, self?.searchController)
        }
        
        viewController?.navigationController?.pushViewController(searchController!, animated: true)
    }
}

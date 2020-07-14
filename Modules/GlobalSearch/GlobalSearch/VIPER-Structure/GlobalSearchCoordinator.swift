import Foundation
import Utility
import Networking
import UIKit

public final class GlobalSearchCoordinator {
    // MARK: Properties
    private var searchController: GlobalSearchViewController?
    
    // MARK: - Constructor
    public init() {}
    
    public func showSearch(from viewController: UIViewController?,
                           withUser user: UserMyself,
                           onTapMessage: @escaping ((EmailMessage, UserMyself) -> Void)) {
        let search: GlobalSearchViewController = UIStoryboard(storyboard: .search,
            bundle: Bundle(for: GlobalSearchViewController.self)).instantiateViewController()
        
        let configurator = GlobalSearchConfigurator()
        configurator.configure(withSearchController: search, user: user, onTapMessage: onTapMessage)
        
        searchController = search
        
        viewController?.navigationController?.pushViewController(searchController!, animated: true)
    }
}

import Foundation
import SideMenu

struct FAQRouter {
    // MARK: Properties
    let viewController: FAQViewController
    
    // MARK: - Actions
    func showInboxSideMenu() {
        viewController.sideMenuController?.revealMenu()
    }
}

import Foundation

struct FAQRouter {
    // MARK: Properties
    let viewController: FAQViewController
    
    // MARK: - Actions
    func showInboxSideMenu() {
        viewController.openLeft()
    }
}

import UIKit

struct FAQPresenter {
    var viewController: FAQViewController?

    func setupNavigationLeftItem() {
        let emptyButton = UIBarButtonItem(image: UIImage(), style: .done, target: self, action: nil)
        if UIDevice.current.orientation.isLandscape {
            viewController?.navigationItem.leftBarButtonItem = emptyButton
        } else {
            viewController?.navigationItem.leftBarButtonItem = viewController?.leftBarButtonItem
        }
    }
}

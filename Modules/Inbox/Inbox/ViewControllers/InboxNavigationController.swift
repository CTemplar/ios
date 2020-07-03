import UIKit
import Utility

class InboxNavigationController: UINavigationController, UINavigationControllerDelegate {

    // MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureNavigationBar()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configureNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func configureNavigationBar() {
        modalPresentationStyle = .formSheet
        navigationBar.isTranslucent = true
        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
        let textAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.StringColor.navigationBarTitle.color]
        navigationBar.titleTextAttributes = textAttributes
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 1 {
            let backBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowDark"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(viewController
                                                    .navigationController?
                                                    .popViewController(animated:)
                )
            )
            viewController.navigationItem.leftBarButtonItem = backBarButton
        } else {
            if let vc = viewController as? LeftBarButtonItemConfigurable {
                vc.setupLeftBarButtonItems()
            } else {
                viewController.navigationItem.leftBarButtonItem = nil
            }
        }
    }
}

import UIKit
import PGPFramework
public class InboxNavigationController: UINavigationController, UINavigationControllerDelegate {

    // MARK: - Lifecycle
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureNavigationBar()
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configureNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func configureNavigationBar() {
        delegate = self
        modalPresentationStyle = .fullScreen
        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationBar.tintColor = AppStyle.Colors.loaderColor.color
        
        if #available(iOS 13.0, *) {
            navigationController?.view.backgroundColor = .systemBackground
            navigationBar.backgroundColor = .systemBackground
            navigationController?.navigationBar.barTintColor = .systemBackground

            let coloredAppearance = UINavigationBarAppearance()
            coloredAppearance.configureWithOpaqueBackground()
            coloredAppearance.backgroundColor = .systemBackground
            let attribute: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.label]
            coloredAppearance.titleTextAttributes = attribute
            coloredAppearance.largeTitleTextAttributes = attribute
            UINavigationBar.appearance().standardAppearance = coloredAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        } else {
            // Fallback on earlier versions
            navigationBar.backgroundColor = .white
            navigationController?.navigationBar.barTintColor = .white
            let textAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.StringColor.navigationBarTitle.color]
            navigationBar.titleTextAttributes = textAttributes
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        navigationController.updateBackgroundColor()
        
        if !(viewController is LeftBarButtonItemConfigurable) {
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
                viewController.navigationItem.leftBarButtonItem = nil
            }
        }
    }
}

import UIKit
import Utility
import IQKeyboardManagerSwift

public class SignupPageViewController: UIPageViewController {
    // MARK: Properties
    private (set) var presenter: SignupPresenter?
    private (set) var router: SignupRouter?
    private (set) var configurator: SignupConfigurator?
    var onSignupComplete: (() -> Void)?
    var pageControl = UIPageControl()
    lazy var orderedViewControllers: [UIViewController] = {
        return [
            self.presenter?.addPageContent(from: SignupViewController.className),
            self.presenter?.addPageContent(from: SignupPasswordViewController.className),
            self.presenter?.addPageContent(from: SignupRecoveryEmailViewController.className)
        ].compactMap({ $0 })
    }()
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = nil
        delegate = self
        view.backgroundColor = UIColor.lightGray
        
        if !IQKeyboardManager.shared.enable {
            IQKeyboardManager.shared.enable = true
        }
        
        configurator = SignupConfigurator(with: self) { [weak self] in
            self?.onSignupComplete?()
        }.configure()
        
        presenter?.setViewControllers()
        presenter?.configure(pageControl: &pageControl)
    }
    
    deinit {
        print("deinit called from \(self.className)")
    }
    
    // MARK: - Setup Viper Stack
    func setup(presenter: SignupPresenter) {
        self.presenter = presenter
        self.presenter?.setup(viewControllerStack: orderedViewControllers)
    }
    
    func setup(router: SignupRouter) {
        self.router = router
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension SignupPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return presenter?.viewController(before: viewController)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return presenter?.viewController(after: viewController)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, finished {
            if let pageContentViewController = pageViewController.viewControllers?.first {
                pageControl.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!
            }
            
        }
    }
}

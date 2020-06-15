import Foundation
import UIKit
import Utility

final class SignupPresenter {
    
    // MARK: Properties
    private var pageViewController: SignupPageViewController
    private var orderedControllers: [UIViewController] = []
    private (set) var formatter: FormatterService
    private (set) var interactor: SignupInteractor?
    
    private var originalPassword = ""
    private var confirmPassword = ""
    
    // MARK: - Constructor
    init(with pageViewController: SignupPageViewController,
         formatter: FormatterService) {
        self.pageViewController = pageViewController
        self.formatter = formatter
    }
    
    // MARK: - Setup
    func setViewControllers() {
        if let firstViewController = orderedControllers.first {
            pageViewController.setViewControllers([firstViewController],
                                                    direction: .forward,
                                                    animated: true,
                                                    completion: nil)
        }
    }
    
    func configure(pageControl: inout UIPageControl) {
        pageControl = UIPageControl()
        pageControl.numberOfPages = orderedControllers.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.clear
        pageControl.pageIndicatorTintColor = k_lightRedColor
        pageControl.currentPageIndicatorTintColor = k_redColor
        pageViewController.view.addSubview(pageControl)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.widthAnchor.constraint(equalToConstant: pageViewController.view.frame.size.width).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: CGFloat(GeneralConstant.PageControlConstant.pageControlDotSize.rawValue)).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: pageViewController.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: pageViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: 8.0).isActive = true
    }

    func setup(viewControllerStack: [UIViewController]) {
        self.orderedControllers = viewControllerStack
    }
    
    func setup(interactor: SignupInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - ViewController Update
    func updateUserExistanceText(by userExistance: UserExistance) {
        if let signupVC = orderedControllers.first as? SignupViewController {
            signupVC.update(by: userExistance)
        }
    }
    
    // MARK: - Page Helpers
    func addPageContent(from viewControllerName: String) -> UIViewController {
        let storyboard = UIStoryboard(storyboard: .signup,
                                      bundle: Bundle(for: type(of: self))
        )
        return storyboard.instantiateViewController(withIdentifier: viewControllerName)
    }
    
    func viewController(before vc: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedControllers.firstIndex(of: vc) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedControllers.count > previousIndex else {
            return nil
        }
        
        return orderedControllers[previousIndex]
    }
    
    func viewController(after vc: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedControllers.firstIndex(of: vc) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        if nextIndex == orderedControllers.count {
            return nil
        }
        
        return orderedControllers[nextIndex]
    }
    
    func showNext(childViewController: UIViewController) {
        guard let viewControllerIndex = orderedControllers.firstIndex(of: childViewController) else {
            return
        }
        
        let nextIndex = viewControllerIndex + 1
        
        if nextIndex == orderedControllers.count {
            return
        }
        
        pageViewController.pageControl.currentPage = nextIndex
        
        let nextViewController = orderedControllers[nextIndex]
        
        pageViewController.setViewControllers([nextViewController],
                                                direction: .forward,
                                                animated: true,
                                                completion: nil)
    }
    
    func showPrevious(of childViewController: UIViewController) {
        guard let viewControllerIndex = orderedControllers.firstIndex(of: childViewController) else {
            return
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return
        }
        
        pageViewController.pageControl.currentPage = previousIndex
        
        let previousViewController = orderedControllers[previousIndex]
        
        pageViewController.setViewControllers([previousViewController],
                                                direction: .reverse,
                                                animated: true,
                                                completion: nil)
    }
    
    // MARK: - Sub-Controllers Config
    func changeButtonState(button: UIButton, disabled: Bool) {
        if disabled {
            button.isEnabled = false
            button.alpha = 0.6
        } else {
            button.isEnabled = true
            button.alpha = 1.0
        }
    }
    
    func changePasswordEntryStyle(_ shouldSecure: Bool, textField: UITextField) {
        textField.isSecureTextEntry = shouldSecure
    }
    
    // MARK: - Password Handler
    func setupPasswordsNextButtonState(childViewController: SignupPasswordViewController, sender: UITextField) {
        guard formatter.validatePasswordLench(enteredPassword: sender.text ?? "") == true,
            formatter.validatePasswordFormat(enteredPassword: sender.text ?? "") == true else {
            childViewController.update(by: .wrongFormat)
            return
        }
        
        switch sender {
        case childViewController.passwordTextField:
            originalPassword = sender.text ?? ""
        case (childViewController.confirmPasswordTextField)!:
            confirmPassword = sender.text ?? ""
        default:
            DPrint("unknown textfield")
        }
        
        if formatter.passwordsMatched(choosedPassword: originalPassword, confirmedPassword: confirmPassword) {
            childViewController.update(by: .matched)
        } else {
            childViewController.update(by: .unMatched)
        }
    }
    
    // MARK: - Email Handler
    func setupEmailNextButtonState(childViewController: SignupRecoveryEmailViewController, sender: UITextField) {
        guard sender.text?.isEmpty == false,
            formatter.validateEmailFormat(enteredEmail: sender.text ?? "") == true else {
                childViewController.update(by: .incorrectEmail)
            return
        }
        childViewController.update(by: .correctEmail)
    }
    
    // MARK: - Data Binding
    func update(userName: String) {
        pageViewController.configurator?.update(userName: userName)
    }
    
    func update(password: String) {
        pageViewController.configurator?.update(password: password)
    }
    
    func update(recoveryEmail: String) {
        pageViewController.configurator?.update(recoveryEmail: recoveryEmail)
    }
    
    func update(invitationCode: String) {
        pageViewController.configurator?.update(invitationCode: invitationCode)
    }
    
    // MARK: - Create Account/Signup
    func createUserAccount() {
        if let signupModel = pageViewController.configurator?.signupModel {
            interactor?.signupUser(using: signupModel)
        }
    }
}

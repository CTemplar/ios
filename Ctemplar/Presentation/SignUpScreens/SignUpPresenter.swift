//
//  SignUpPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class SignUpPresenter {
    
    var viewController   : SignUpPageViewController?
    var interactor       : SignUpInteractor?
    var formatterService : FormatterService?
    
    func setViewControllers() {
        
        if let firstViewController = self.viewController?.orderedViewControllers.first {
            self.viewController?.setViewControllers([firstViewController],
                                                    direction: .forward,
                                                    animated: true,
                                                    completion: nil)
        }
    }
    
    func configurePageControl() {
        
        let bottomOffset : Double = Double(UIScreen.main.bounds.maxY) - k_pageControlBottomOffset
        
        self.viewController?.pageControl = UIPageControl(frame: CGRect(x: 0.0, y: bottomOffset, width: Double(UIScreen.main.bounds.width), height:  k_pageControlDotSize))
        self.viewController?.pageControl.numberOfPages = (self.viewController?.orderedViewControllers.count)!
        self.viewController?.pageControl.currentPage = 0
        self.viewController?.pageControl.tintColor = UIColor.clear
        self.viewController?.pageControl.pageIndicatorTintColor = k_lightRedColor
        self.viewController?.pageControl.currentPageIndicatorTintColor = k_redColor        
        self.viewController?.view.addSubview((self.viewController?.pageControl)!)
    }
    
    func setPageControlFrame() {
        
        let screenBoundsMax =  self.viewController?.view.bounds.maxX
        let screenWidth = self.viewController?.view.bounds.width
        
        let bottomOffset : Double = Double(screenBoundsMax!) - k_pageControlBottomOffset
        
        self.viewController?.pageControl.frame = CGRect(x: 0.0, y: bottomOffset, width: Double(screenWidth!), height:  k_pageControlDotSize)
    }
    
    func viewControllerBefore(viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = self.viewController?.orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            
            return nil
        }
        
        guard (self.viewController?.orderedViewControllers.count)! > previousIndex else {
            return nil
        }
        
        return self.viewController?.orderedViewControllers[previousIndex]
    }
    
    func viewControllerAfter(viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = self.viewController?.orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = self.viewController?.orderedViewControllers.count
                
        if nextIndex == orderedViewControllersCount {
            return nil
        }
        
        return self.viewController?.orderedViewControllers[nextIndex]
    }
    
    func addPageContent(viewController: String) -> UIViewController {
        
        var storyboardName : String? = k_SignUpStoryboardName
        
        if (Device.IS_IPAD) {
            storyboardName = k_SignUpStoryboardName_iPad
        }
        
        return UIStoryboard(name: storyboardName!, bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    //MARK: - Child View Controllers functional
    
    func userNameHintLabel(show: Bool, childViewController: SignUpPageNameViewController) {
       
        if show {
            childViewController.userNameHintLabel.isHidden = false
            childViewController.userNameTextField.placeholder = ""
        } else {
            if !(formatterService?.validateNameLench(enteredName: (childViewController.userNameTextField.text)!))! {
                childViewController.userNameTextField.placeholder = "usernamePlaceholder".localized()
                childViewController.userNameHintLabel.isHidden = true
            }
        }
    }
    
    func setupUsernamePageNextButtonState(childViewController: SignUpPageNameViewController) {

        if (formatterService?.validateNameFormat(enteredName: (viewController?.userName)!))! {
            changeButtonState(button: childViewController.nextButton, disabled: false)
        } else {
            changeButtonState(button: childViewController.nextButton, disabled: true)
        }
    }
    
    //MARK: - New Password Screen
    
    func passwordsHintLabel(show: Bool, sender: UITextField, childViewController: SignUpPagePasswordViewController) {
        
        if sender == childViewController.choosePasswordTextField {
            if show {
                childViewController.choosePasswordHintLabel.isHidden = false
                childViewController.choosePasswordTextField.placeholder = ""
            } else {
                if !(formatterService?.validateNameLench(enteredName: (childViewController.choosePasswordTextField.text)!))! {
                    childViewController.choosePasswordTextField.placeholder = "choosePasswordPlaceholder".localized()
                    childViewController.choosePasswordHintLabel.isHidden = true
                }
            }
        }
        
        if sender == childViewController.confirmPasswordTextField {
            if show {
                childViewController.confirmPasswordHintLabel.isHidden = false
                childViewController.confirmPasswordTextField.placeholder = ""
            } else {
                if !(formatterService?.validateNameLench(enteredName: (childViewController.confirmPasswordTextField.text)!))! {
                    childViewController.confirmPasswordTextField.placeholder = "confirmPasswordPlaceholder".localized()
                    childViewController.confirmPasswordHintLabel.isHidden = true
                }
            }
        }
    }
    
    func setupPasswordsNextButtonState(childViewController: SignUpPagePasswordViewController, sender: UITextField) {
        
        switch sender {
        case (childViewController.choosePasswordTextField)!:
            print("choosePasswordTextField typed:", sender.text!)
            childViewController.choosedPassword = sender.text
        case (childViewController.confirmPasswordTextField)!:
            print("confirmPasswordTextField typed:", sender.text!)
            childViewController.confirmedPassword = sender.text
        default:
            print("unknown textfield")
        }
        
        if ((formatterService?.passwordsMatched(choosedPassword: childViewController.choosedPassword! , confirmedPassword: childViewController.confirmedPassword!))!) {
            print("passwords matched")
            viewController?.password = childViewController.choosedPassword
            
            if ((formatterService?.validatePasswordFormat(enteredPassword: (viewController?.password)!))!) {
                changeButtonState(button: childViewController.nextButton, disabled: false)
            } else {
                print("password wrong format")
                changeButtonState(button: childViewController.nextButton, disabled: true)
            }
        } else {
            print("passwords not matched!!!")
            viewController?.password = ""
            changeButtonState(button: childViewController.nextButton, disabled: true)
        }
    }
    
    //MARK: - Recovery Email Screen
    
    func recoveryEmailHintLabel(show: Bool, childViewController: SignUpPageEmailViewController) {
        
        if show {
            childViewController.recoveryEmailHintLabel.isHidden = false
            childViewController.recoveryEmailTextField.placeholder = ""
        } else {
            if !(formatterService?.validateNameLench(enteredName: (childViewController.recoveryEmailTextField.text)!))! {
                childViewController.recoveryEmailTextField.placeholder = "recoveryEmailPlaceholder".localized()
                childViewController.recoveryEmailHintLabel.isHidden = true
            }
        }
    }
    
    func setupRecoveryEmailNextButtonState(childViewController: SignUpPageEmailViewController) {
        
        if childViewController.termsBoxChecked {
            if (formatterService?.validateNameLench(enteredName: (viewController?.recoveryEmail)!))! {
                if (formatterService?.validateEmailFormat(enteredEmail:(viewController?.recoveryEmail)!))! {
                    changeButtonState(button: childViewController.createAccountButton, disabled: false)
                } else {
                    changeButtonState(button: childViewController.createAccountButton, disabled: true)
                }
            } else {
                changeButtonState(button: childViewController.createAccountButton, disabled: false)
            }
        } else {
            changeButtonState(button: childViewController.createAccountButton, disabled: true)
        }
    }
    
    func changeButtonState(button: UIButton, disabled: Bool) {
        
        if disabled {
            button.isEnabled = false
            button.alpha = 0.6
        } else {
            button.isEnabled = true
            button.alpha = 1.0
        }
    }
    
    func pressedCheckBoxButton(childViewController: SignUpPageEmailViewController) {
        
        childViewController.termsBoxChecked = !childViewController.termsBoxChecked
        
        var checkBoxImage: UIImage?
        
        if childViewController.termsBoxChecked {
            checkBoxImage = UIImage.init(named: k_checkBoxSelectedImageName)
        } else {
            checkBoxImage = UIImage.init(named: k_checkBoxUncheckedImageName)
        }
        
        childViewController.checkBoxButton.setBackgroundImage(checkBoxImage, for: .normal)
        
        setupRecoveryEmailNextButtonState(childViewController: childViewController)
    }

    func showNextViewController(childViewController: UIViewController) {
        
       // guard let nextViewController = self.viewController?.dataSource?.pageViewController(self.viewController!, viewControllerAfter: childViewController ) else { return }
        
        guard let viewControllerIndex = self.viewController?.orderedViewControllers.index(of: childViewController) else {
            return
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = self.viewController?.orderedViewControllers.count
        
        if nextIndex == orderedViewControllersCount {
            return
        }
        
        self.viewController?.pageControl.currentPage = nextIndex
        
        guard let nextViewController = self.viewController?.orderedViewControllers[nextIndex] else { return }
        
        
        self.viewController?.setViewControllers([nextViewController],
                                                direction: .forward,
                                                animated: true,
                                                completion: nil)
    }
    
    func showPreviousViewController(childViewController: UIViewController) {
        
       // guard let previousViewController = self.viewController?.dataSource?.pageViewController(self.viewController!, viewControllerBefore: childViewController ) else { return }
        
        guard let viewControllerIndex = self.viewController?.orderedViewControllers.index(of: childViewController) else {
            return
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            
            return
        }
        
        self.viewController?.pageControl.currentPage = previousIndex
        
        guard let previousViewController = self.viewController?.orderedViewControllers[previousIndex] else { return }
 
        
        self.viewController?.setViewControllers([previousViewController],
                                                direction: .reverse,
                                                animated: true,
                                                completion: nil)
    }
    
    func createUserAccount() {
        
        self.interactor?.signUpUser(userName: (self.viewController?.userName)!, password: (self.viewController?.password)!, recoveryEmail: (self.viewController?.recoveryEmail)!)
        
        //self.interactor?.signUpUser(userName: "test", password: "test123", recoveryEmail: "test@test.com")
    }
    
    func pressedNextButton(childViewController: UIViewController) {
        
        if let userName = self.viewController?.userName {
            self.interactor?.checkUser(userName: userName, childViewController: childViewController)
        }
    }
}

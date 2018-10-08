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
        
        return UIStoryboard(name: k_SignUpStoryboardName, bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    //MARK: - Child View Controllers functional
    
    func setupNameTextFieldAndHintLabel(childViewController: SignUpPageNameViewController) {
        
        if (formatterService?.validateNameLench(enteredName: (viewController?.userName)!))! {
            childViewController.userNameHintLabel.isHidden = false
        } else {
            childViewController.userNameHintLabel.isHidden = true
        }
        
        if (formatterService?.validateNameFormat(enteredName: (viewController?.userName)!))! {
            
        } else {
            print("wrong Name format")
        }
    }
    
    func setupPasswordTextFieldsAndHintLabels(childViewController: SignUpPagePasswordViewController, sender: UITextField) {
        
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
        
        if (formatterService?.validatePasswordLench(enteredPassword: childViewController.choosedPassword!))! {
            childViewController.choosePasswordHintLabel.isHidden = false
        } else {
            childViewController.choosePasswordHintLabel.isHidden = true
        }
        
        if (formatterService?.validatePasswordLench(enteredPassword: childViewController.confirmedPassword!))! {
            childViewController.confirmPasswordHintLabel.isHidden = false
        } else {
            childViewController.confirmPasswordHintLabel.isHidden = true
        }
        
        if ((formatterService?.passwordsMatched(choosedPassword: childViewController.choosedPassword! , confirmedPassword: childViewController.confirmedPassword!))!) {
            print("passwords matched")
            viewController?.password = childViewController.choosedPassword
        } else {
            viewController?.password = ""
            print("passwords not matched!!!")
        }
    }
    
    func setupRecoveryEmailTextFieldAndHintLabel(childViewController: SignUpPageEmailViewController) {
        
        if (formatterService?.validateNameLench(enteredName: (viewController?.recoveryEmail)!))! {
            childViewController.recoveryEmailHintLabel.isHidden = false
        } else {
            childViewController.recoveryEmailHintLabel.isHidden = true
        }
        
        if (formatterService?.validateEmailFormat(enteredEmail:(viewController?.recoveryEmail)!))! {
            
        } else {
            print("wrong Email format")
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
    }

    func nextViewController(childViewController: UIViewController) {
        
        guard let nextViewController = self.viewController?.dataSource?.pageViewController(self.viewController!, viewControllerAfter: childViewController ) else { return }
        
        guard let viewControllerIndex = self.viewController?.orderedViewControllers.index(of: childViewController) else {
            return
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = self.viewController?.orderedViewControllers.count
        
        if nextIndex == orderedViewControllersCount {
            return
        }
        
        self.viewController?.pageControl.currentPage = nextIndex
        
         /*
        guard let nextViewController = self.viewController?.orderedViewControllers[nextIndex] else { return }
        */
        
        self.viewController?.setViewControllers([nextViewController],
                                                direction: .forward,
                                                animated: true,
                                                completion: nil)
    }
    
    func createUserAccount() {
        
        self.interactor?.signUpUser(userName: (self.viewController?.userName)!, password: (self.viewController?.password)!, recoveryEmail: (self.viewController?.recoveryEmail)!)
        
        //self.interactor?.signUpUser(userName: "test", password: "test123", recoveryEmail: "test@test.com")
    }
}

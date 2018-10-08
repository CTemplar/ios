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
    
    var viewController  : SignUpPageViewController?
    var interactor      : SignUpInteractor?
    
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
    
    func setupNameTextFieldsAndHintLabel(childViewController: SignUpPageNameViewController) {
        
        if (interactor?.validateNameLench(enteredName: childViewController.userName!))! {
            childViewController.userNameHintLabel.isHidden = false
        } else {
            childViewController.userNameHintLabel.isHidden = true
        }
    }

    func nextViewController(childViewController: UIViewController) {
        
        guard let nextViewController = self.viewController?.dataSource?.pageViewController(self.viewController!, viewControllerAfter: childViewController ) else { return }
        
        self.viewController?.setViewControllers([nextViewController],
                                                direction: .forward,
                                                animated: true,
                                                completion: nil)
    }
}

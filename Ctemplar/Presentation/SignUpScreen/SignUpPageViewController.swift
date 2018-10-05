//
//  SignUpPageViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit
import Foundation

class SignUpPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UITextFieldDelegate {
   
    var presenter   : SignUpPresenter?
    var router      : SignUpRouter?
    
    var pageControl = UIPageControl()
        
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.presenter?.addPageContent(viewController: k_SignUpPageNameViewControllerID),
                self.presenter?.addPageContent(viewController: k_SignUpPagePasswordViewControllerID),
                self.presenter?.addPageContent(viewController: k_SignUpPageEmailViewControllerID)]
        }() as! [UIViewController]
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = SignUpConfigurator()
        configurator.configure(viewController: self)
        
        self.dataSource = self
        self.delegate = self
        self.presenter?.setViewControllers()
        self.presenter?.configurePageControl()
        
        self.view.backgroundColor = UIColor.lightGray
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return self.presenter?.viewControllerBefore(viewController: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.presenter?.viewControllerAfter(viewController: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (completed && finished) {
            let pageContentViewController = pageViewController.viewControllers![0]
            self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
}

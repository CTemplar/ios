//
//  SplitViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.01.2019.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var apiService      : APIService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.preferredDisplayMode = .automatic
        /*
           
        if let mainViewController = self.secondaryViewController as? MainViewController {
        
            print("mainViewController:", mainViewController)
            
            let inboxViewController = mainViewController.inboxNavigationController.viewControllers.first as! InboxViewController
            
            if let navigationController = self.primaryViewController as? UINavigationController {
                
                if let sideMenuViewController = navigationController.topViewController as? InboxSideMenuViewController {
                    
                    sideMenuViewController.inboxViewController = inboxViewController
                    print("sideMenuViewController:", sideMenuViewController)
                }
            }
        }*/
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return true
    }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        
        print("displayMode:", displayMode.rawValue)
    }
    
    func showLoginViewController() {
        
        print("show iPad login VC")
        
        DispatchQueue.main.async {
            
            var storyboardName : String? = k_LoginStoryboardName
            
            if (Device.IS_IPAD) {
                storyboardName = k_LoginStoryboardName_iPad
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_LoginViewControllerID) as! LoginViewController
            //vc.mainViewController = self
            self.show(vc, sender: self)
        }
    }
}

extension UISplitViewController {
    
    func toggleMasterView() {
        let barButtonItem = self.displayModeButtonItem
        UIApplication.shared.sendAction(barButtonItem.action!, to: barButtonItem.target, from: nil, for: nil)
    }
    
    var primaryViewController: UIViewController? {
        return self.viewControllers.first
    }
    
    var secondaryViewController: UIViewController? {
        return self.viewControllers.count > 1 ? self.viewControllers[1] : nil
    }
}

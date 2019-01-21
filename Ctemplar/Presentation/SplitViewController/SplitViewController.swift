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
    
    var mainViewController: MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.preferredDisplayMode = .automatic
        self.preferredPrimaryColumnWidthFraction = 0.34
        
        if let inboxNavigationViewController = self.secondaryViewController as? InboxNavigationController {
            
            let inboxViewController = inboxNavigationViewController.viewControllers.first as! InboxViewController
            
            if let navigationController = self.primaryViewController as? UINavigationController {
                
                if let sideMenuViewController = navigationController.topViewController as? InboxSideMenuViewController {
                    
                    sideMenuViewController.inboxViewController = inboxViewController
                    sideMenuViewController.mainViewController = self.mainViewController
                    print("sideMenuViewController:", sideMenuViewController)
                }
            }
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return true
    }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        
        print("displayMode:", displayMode.rawValue)
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

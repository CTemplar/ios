//
//  SplitViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.01.2019.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class SplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = .automatic       
        //self.primaryEdge = .leading
        
        /*
        let navigationController = self.viewControllers.last as? UINavigationController
        
        navigationController?.topViewController?.navigationItem.leftBarButtonItem = self.displayModeButtonItem
        navigationController?.topViewController?.navigationItem.leftItemsSupplementBackButton = true
        */
        /*
        let detailViewController = self.viewControllers.first as! UINavigationController
        
        detailViewController.navigationItem.leftBarButtonItem = self.displayModeButtonItem
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        
        for vc in self.viewControllers {
            print("vc:", vc)
        }*/
        
    }
}

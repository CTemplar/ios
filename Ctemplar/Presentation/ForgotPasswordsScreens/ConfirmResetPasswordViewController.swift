//
//  ConfirmResetPasswordViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ConfirmResetPasswordViewController: UIViewController {
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        /*
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
 
        */
        
        navigationController?.navigationBar.backgroundColor = UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
    }
    
    func setDefaultNavigationBar() {
        
        UINavigationBar.appearance().setBackgroundImage(nil, for: UIBarMetrics.default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = nil
        // Sets the translucent background color
        //UINavigationBar.appearance().backgroundColor = k_whiteColor
    }
}

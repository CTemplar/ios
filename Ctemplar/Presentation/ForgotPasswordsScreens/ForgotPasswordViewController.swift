//
//  ForgotPasswordViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ForgotPasswordViewController: UIViewController {
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupNavigationBar()

    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        setDefaultNavigationBar()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonPressed(_ sender: AnyObject) {
        
        //temp
        let storyboard: UIStoryboard = UIStoryboard(name: k_ForgotPasswordStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ConfirmResetPasswordViewControllerID) as! ConfirmResetPasswordViewController
        self.show(vc, sender: self)
        //self.present(vc, animated: true, completion: nil)
       
    }
    
    @IBAction func forgotUsernameButtonPressed(_ sender: AnyObject) {
        
        
    }
    
    func setupNavigationBar() {
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
    }
    
    func setDefaultNavigationBar() {
        
        UINavigationBar.appearance().setBackgroundImage(nil, for: UIBarMetrics.default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = nil
        // Sets the translucent background color
        //UINavigationBar.appearance().backgroundColor = k_whiteColor
    }
}

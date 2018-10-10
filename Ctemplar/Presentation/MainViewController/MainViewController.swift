//
//  ViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit
import Foundation
import PKHUD
import AlertHelperKit

class MainViewController: UIViewController { 
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var apiService      : APIService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configurePKHUD()
        showLoginViewController()
        /*
        apiService = appDelegate.applicationManager.apiService
        apiService?.messagesList() {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let emailMessage = value as! EmailMessage
                
                for result in emailMessage.messageResultsList! {
                    //print("result", result)
                    print("content:", result.content as Any)
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self, title: "Messages Error", message: error.localizedDescription, button: "Close")
            }
        }*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
        //    self.apiService?.messagesList(viewController: self)
        }
    }
    
    func configurePKHUD() {
        
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
    }
    
    func showLoginViewController() {
        
        DispatchQueue.main.async {
            let storyboard: UIStoryboard = UIStoryboard(name: k_LoginStoryboardName, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_LoginViewControllerID) as! LoginViewController
            self.show(vc, sender: self)
        }
    }
}


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

class ViewController: UIViewController { //Temp Main Controller
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var apiService      : APIService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        
        
        showLoginViewController()

        /*
        apiService = appDelegate.applicationManager.apiService
        
        authenticateUser(userName: "nitish", password: "admin1234") {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("success:", value) //token value
                
                if let response = value as? Dictionary<String, Any> {
                    for dictionary in response {
                        //print("dictionary key:", dictionary.key, "/ value:", dictionary.value)
                        
                        if dictionary.key == "token" {
                            print("token:", dictionary.value)
                        }
                    }
                }
         
            case .failure(let error):
                print("error:", error.localizedDescription)
            }
        }*/
        
        /*
         password =     (
            "This field may not be blank."
         );
         username =     (
            "This field may not be blank."
         );
         
         "non_field_errors" =     (
            "Unable to log in with provided credentials."
         );
         
         {
         token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJvcmlnX2lhdCI6MTUzODQ3MTIwOSwidXNlcm5hbWUiOiJuaXRpc2giLCJ1c2VyX2lkIjoxLCJleHAiOjE1Mzg0ODIwMDl9.K95PlIwkeS1-gl4iWaDo579jNPyYKzbb4ZefZa1FneU";
         }
 */
    }
    
    func authenticateUser(userName: String, password: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        apiService?.authenticateUser(userName: userName, password: password, completionHandler: completionHandler)
    }

    func showLoginViewController() {
        
        DispatchQueue.main.async {
            let storyboard: UIStoryboard = UIStoryboard(name: k_LoginStoryboardName, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_LoginViewControllerID) as! LoginViewController
            self.show(vc, sender: self)
        }
    }
}


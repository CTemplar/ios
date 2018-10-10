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
        
        apiService = appDelegate.applicationManager.apiService
        
        configurePKHUD()
        
        //showLoginViewController()
        messagesList()
        //mailboxesList()

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
    
    func messagesList() {
        
        apiService?.messagesList() {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let emailMessage = value as! EmailMessage
                
                for result in emailMessage.messageResultsList! {
                    //print("result", result)
                    
                    if let content = result.content {
                        print("content:", content)
                        self.decryptMessage(encryptedContet: content)
                    }
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self, title: "Messages Error", message: error.localizedDescription, button: "Close")
            }
        }
    }
    
    func mailboxesList() {
        
        apiService?.mailboxesList() {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("Mailboxes value:", value)
                
                let mailbox = value as! Mailbox
                
                for result in mailbox.mailboxesResultsList! {
                    //print("result", result)
                    print("privateKey:", result.privateKey as Any)
                    print("publicKey:", result.publicKey as Any)
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self, title: "Mailboxes Error", message: error.localizedDescription, button: "Close")
            }
        }
    }
    
    func decryptMessage(encryptedContet: String) {
        
        let pgpService = appDelegate.applicationManager.pgpService
        
        if let contentData = encryptedContet.data(using: .ascii) {
            if let decodedData = pgpService.decrypt(encryptedData: contentData) {
                let decryptedMessage = pgpService.decodeData(decryptedData: decodedData)
                print("decryptedMessage:", decryptedMessage)
            }
        }
    }
}


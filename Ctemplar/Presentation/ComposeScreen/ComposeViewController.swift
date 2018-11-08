//
//  ComposeViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 12.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit
import Foundation
import PKHUD
import AlertHelperKit

class ComposeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.navigationController?.navigationItem.title = "XXX"
        
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        
        sendMail()
        
    }
    
    //temp
    
    func sendMail() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let apiService = appDelegate.applicationManager.apiService
        
        apiService.createMessage(content: "xxxxxxx", folder: "inbox") {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("createMessage value:", value)
                
                
                
            case .failure(let error):
                print("error:", error)
                //AlertHelperKit().showAlert(self.viewController!, title: "Mailboxes Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}

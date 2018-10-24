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
        showInboxNavigationController()
        //messagesList()
        //mailboxesList()
        
        /*
        apiService?.verifyToken() {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("value:", value)
                
            case .failure(let error):
                print("error:", error)
            }
        }*/
        
        /*
        let keyChainService = apiService?.keychainService
        let formatterService = apiService?.formatterService
        
        if let tokenSavedTime = keyChainService?.getTokenSavedTime() {
            if tokenSavedTime.count > 0 {
                //2018-10-24 05:51:21 +0000
                if let tokenSavedDate = formatterService?.formatTokenTimeStringToDate(date: tokenSavedTime) {
                    print("tokenSavedDate:", tokenSavedDate)
                
                    let minutesCount = tokenSavedDate.minutesCountForTokenExpiration()
                    print("minutesCount", minutesCount)
                    
                    /*
                    if let hoursCount = formatterService?.calculateHoursCountFor(date: tokenSavedDate) {
                        print("hoursCount", hoursCount)
                        if hoursCount > 2 {
                            //
                        }
                    }*/
                }
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
            
            var storyboardName : String? = k_LoginStoryboardName
            
            if (Device.IS_IPAD) {
                storyboardName = k_LoginStoryboardName_iPad
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_LoginViewControllerID) as! LoginViewController
            self.show(vc, sender: self)
        }
    }
    
    func showInboxNavigationController() {
        
        DispatchQueue.main.async {
            
            let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_InboxNavigationControllerID) as! InboxNavigationController
            self.show(vc, sender: self)
        }
    }
    
    func messagesList() {
        
        apiService?.messagesList() {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let emailMessages = value as! EmailMessagesList
                
                for result in emailMessages.messagesList! {
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
                    
                    self.getPGPKeyFromString(key: result.privateKey!)
                    self.getPGPKeyFromString(key: result.publicKey!)
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
            } else {
                print("decrypting failed")
            }
        }
    }
    
    func getPGPKeyFromString(key: String) {
        
        let pgpService = appDelegate.applicationManager.pgpService
        
        if let pgpKeys = pgpService.readPGPKeysFromString(key: key) {            
            for pgpKey in pgpKeys {
                pgpService.savePGPKey(pgpKey: pgpKey)
            }
        }
        /*
        if let storedKey = pgpService.getStoredPGPKey() {
            print("stored key", storedKey)
        }*/
    }
}

@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
}

@IBDesignable
class DesignableLabel: UILabel {
}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}



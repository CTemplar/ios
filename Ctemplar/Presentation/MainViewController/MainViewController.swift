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
import SideMenu

class MainViewController: UIViewController { 
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var apiService      : APIService?
    
    var inboxNavigationController: InboxNavigationController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        apiService = appDelegate.applicationManager.apiService
        
        configurePKHUD()
        
        //showLoginViewController()
        //showInboxNavigationController()
        
        initInboxNavigationController()
       
        let keyChainService = apiService?.keychainService
        let storedUserName = keyChainService?.getUserName()
        let storedPassword = keyChainService?.getPassword()
        
        if (storedUserName?.count)! < 1 || (storedPassword?.count)! < 1 {
            print("MainViewController: wrong stored credentials!")
            DispatchQueue.main.async {
            //    self.apiService?.showLoginViewController()
            }
            showLoginViewController()
            //showInboxNavigationController()
        } else {
            showInboxNavigationController()
        }
        
        
        
        //messagesList()
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
        
        print("show login VC")
        
        DispatchQueue.main.async {
            
            var storyboardName : String? = k_LoginStoryboardName
            
            if (Device.IS_IPAD) {
                storyboardName = k_LoginStoryboardName_iPad
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_LoginViewControllerID) as! LoginViewController
            vc.mainViewController = self
            self.show(vc, sender: self)
        }
    }
    
    func showInboxNavigationController() {
        DispatchQueue.main.async {
            self.show(self.inboxNavigationController, sender: self)
        }
    }
    
    func initInboxNavigationController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
        self.inboxNavigationController = storyboard.instantiateViewController(withIdentifier: k_InboxNavigationControllerID) as? InboxNavigationController
       
        let inboxViewController = self.inboxNavigationController.viewControllers.first as! InboxViewController
        
        self.initAndSetupInboxSideMenuController(inboxViewController: inboxViewController)
    }
    
    /*
    func showInboxNavigationController() {
        
        DispatchQueue.main.async {
            
            let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_InboxNavigationControllerID) as! InboxNavigationController
            self.show(vc, sender: self)
            
            self.initAndSetupInboxSideMenuController(inboxViewController: vc.viewControllers.first as! InboxViewController)
        }
    }*/
    
    //MARK: - Side Menu
    
    func initAndSetupInboxSideMenuController(inboxViewController: InboxViewController) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxSideMenuStoryboardName, bundle: nil)
        
        let inboxSideMenuViewController = storyboard.instantiateViewController(withIdentifier: k_InboxSideMenuViewControllerID) as? InboxSideMenuViewController
        
        inboxSideMenuViewController?.mainViewController = self
        inboxSideMenuViewController?.inboxViewController = inboxViewController
        inboxSideMenuViewController?.dataSource?.selectedIndexPath = IndexPath(row: MessagesFoldersName.inbox.hashValue, section: SideMenuSectionIndex.mainFolders.rawValue)
        
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: (inboxSideMenuViewController)!)
        
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuAnimationFadeStrength = 0.5
        SideMenuManager.default.menuAnimationBackgroundColor = k_sideMenuFadeColor
        
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        let frame = self.view.frame
        SideMenuManager.default.menuWidth = max(round(min((frame.width), (frame.height)) * 0.67), 240)
    }
    
    func messagesList() {
        
        apiService?.messagesList(folder: "inbox", messagesIDIn: "", seconds: 0) {(result) in
            
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
                AlertHelperKit().showAlert(self, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func mailboxesList() {
        
        apiService?.mailboxesList() {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("Mailboxes value:", value)
                
                let mailboxes = value as! Mailboxes
                
                for result in mailboxes.mailboxesResultsList! {
                    //print("result", result)
                    print("privateKey:", result.privateKey as Any)
                    print("publicKey:", result.publicKey as Any)
                    
                    self.getPGPKeyFromString(key: result.privateKey!)
                    self.getPGPKeyFromString(key: result.publicKey!)
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self, title: "Mailboxes Error", message: error.localizedDescription, button: "closeButton".localized())
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
    
    func addBlurEffect() {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    
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



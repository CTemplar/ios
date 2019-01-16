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
    var iPadSplitViewController : SplitViewController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        apiService = appDelegate.applicationManager.apiService
        
        configurePKHUD()
        
        if (!Device.IS_IPAD) {
            initInboxNavigationController()
        } else {
            initSplitViewController()
        }
       
        let keyChainService = apiService?.keychainService
        let storedUserName = keyChainService?.getUserName()
        let storedPassword = keyChainService?.getPassword()
        
        if (storedUserName?.count)! < 1 || (storedPassword?.count)! < 1 {
            print("MainViewController: wrong stored credentials!")
            showLoginViewController()
        } else {
            if (!Device.IS_IPAD) {
                showInboxNavigationController()
            } else {
                showSplitViewController()
            }
        }
        
        
        setAutoUpdaterTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
 
    }
    
    func setAutoUpdaterTimer() {
        
        Timer.scheduledTimer(timeInterval: 30,
                             target: self,
                             selector: #selector(self.sendUpdateNotification),
                             userInfo: nil,
                             repeats: true)
    }
    
    @objc func sendUpdateNotification() {
        
        let silent = true
        NotificationCenter.default.post(name: Notification.Name(k_updateInboxMessagesNotificationID), object: silent, userInfo: nil)
        print("sendUpdateNotification")
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
        
        if (!Device.IS_IPAD) {
            self.initAndSetupInboxSideMenuController(inboxViewController: inboxViewController)
        } else {
                        
        }
    }
    
    //MARK: - Side Menu
    
    func initAndSetupInboxSideMenuController(inboxViewController: InboxViewController) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxSideMenuStoryboardName, bundle: nil)
        
        let inboxSideMenuViewController = storyboard.instantiateViewController(withIdentifier: k_InboxSideMenuViewControllerID) as? InboxSideMenuViewController
        
        inboxSideMenuViewController?.mainViewController = self
        inboxSideMenuViewController?.inboxViewController = inboxViewController
        inboxSideMenuViewController?.dataSource?.selectedIndexPath = IndexPath(row: 0, section: SideMenuSectionIndex.mainFolders.rawValue)
        
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: (inboxSideMenuViewController)!)
        
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuAnimationFadeStrength = 0.5
        SideMenuManager.default.menuAnimationBackgroundColor = k_sideMenuFadeColor
        
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        let frame = self.view.frame
        SideMenuManager.default.menuWidth = max(round(min((frame.width), (frame.height)) * 0.67), 240)
    }
    
    func initSplitViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SplitStoryboardName, bundle: nil)
        self.iPadSplitViewController = storyboard.instantiateViewController(withIdentifier: k_SplitViewControllerID) as? SplitViewController
    }
    
    func showSplitViewController() {
        
        DispatchQueue.main.async {
            self.show(self.iPadSplitViewController , sender: self)
        }
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

extension UINavigationBar {
    
    func showBorderLine() {
        findBorderLine().isHidden = false
    }
    
    func hideBorderLine() {
        findBorderLine().isHidden = true
    }
    
    private func findBorderLine() -> UIImageView! {
        return self.subviews
            .flatMap { $0.subviews }
            .compactMap { $0 as? UIImageView }
            .filter { $0.bounds.size.width == self.bounds.size.width }
            .filter { $0.bounds.size.height <= 2 }
            .first
    }
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



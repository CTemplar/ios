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

class MainViewController: UIViewController, HashingService {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var apiService      : APIService?
    
    var inboxNavigationController: InboxNavigationController! = nil
    var iPadSplitViewController : SplitViewController! = nil
    
    var mainTimer: Timer!
    
    var messageID = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        apiService = appDelegate.applicationManager.apiService
        
        configurePKHUD()
        
        initInboxNavigationController()
        
        if (Device.IS_IPAD) {
            initSplitViewController()
        }
        
        let keyChainService = apiService?.keychainService
        let isRememberMeEnabled = keyChainService?.getRememberMeValue() ?? false
        let twoFAstatus = keyChainService?.getTwoFAstatus() ?? true
        
        if (isRememberMeEnabled && (apiService?.canTokenRefresh() ?? false)) || (apiService?.isTokenValid() ?? false) {
            moveToNext()
        }else if isRememberMeEnabled && !twoFAstatus {
            let username = keyChainService?.getUserName() ?? ""
            let password = keyChainService?.getPassword() ?? ""
            authenticateUser(with: username, and: password)
        }else {
            showLoginViewController()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
 
    }
    
    func moveToNext() {
        if (!Device.IS_IPAD) {
            showInboxNavigationController()
        } else {
            showSplitViewController()
        }
    }
    
    func setAutoUpdaterTimer() {
        
        print("start AutoUpdaterTimer")
        
        mainTimer = Timer.scheduledTimer(timeInterval: 60,
                             target: self,
                             selector: #selector(self.sendUpdateNotification),
                             userInfo: nil,
                             repeats: true)
    }
    
    func stopAutoUpdaterTimer() {
        
        if mainTimer != nil {
            print("stop AutoUpdaterTimer")
            mainTimer.invalidate()
            mainTimer = nil
        }
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
            
            var storyboardName : String = k_LoginStoryboardName
            
            if (Device.IS_IPAD) {
                storyboardName = k_LoginStoryboardName_iPad
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_LoginViewControllerID) as! LoginViewController
            vc.mainViewController = self
            vc.modalPresentationStyle = .fullScreen
            self.show(vc, sender: self)
        }
    }
    
    func showInboxNavigationController() {
        DispatchQueue.main.async {
            self.inboxNavigationController.modalPresentationStyle = .fullScreen
            self.show(self.inboxNavigationController, sender: self)
        }
    }
    
    func initInboxNavigationController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
        self.inboxNavigationController = storyboard.instantiateViewController(withIdentifier: k_InboxNavigationControllerID) as? InboxNavigationController
       
        let inboxViewController = self.inboxNavigationController.viewControllers.first as! InboxViewController
        inboxViewController.messageID = messageID
        if (!Device.IS_IPAD) {
            self.initAndSetupInboxSideMenuController(inboxViewController: inboxViewController)
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
        self.iPadSplitViewController.mainViewController = self
        
        self.iPadSplitViewController.showDetailViewController(self.inboxNavigationController, sender: self)
    }
    
    func showSplitViewController() {
        
        DispatchQueue.main.async {
            self.iPadSplitViewController.modalPresentationStyle = .fullScreen
            self.show(self.iPadSplitViewController , sender: self)
        }
    }
}

//MARK: - Authentication

extension MainViewController {
    func authenticateUser(with username: String, and password: String) {
        HUD.show(.progress)
        generateHashedPassword(for: username, password: password) { (result) in
            guard let value = try? result.get() else {
                HUD.hide()
                self.showLoginViewController()
                return
            }
            AppManager.shared.networkService.loginUser(with: LoginDetails(userName: username, password: value, twoFAcode: nil)) { (result) in
                HUD.hide()
                switch result {
                case .success(let value):
                    if let token = value.token {
                        self.apiService?.keychainService?.saveToken(token: token)
                        self.moveToNext()
                    }else {
                        self.showLoginViewController()
                    }
                    break
                case .failure(_):
                    self.showLoginViewController()
                    break
                }
            }
        }
    }
}




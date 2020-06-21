//
//  ViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import UIKit
import Foundation
import Utility
import Networking
import Login

class MainViewController: UIViewController, HashingService {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var apiService      : APIService?
    
//    var inboxNavigationController: InboxNavigationController! = nil
//    var iPadSplitViewController : SplitViewController! = nil
    
    var mainTimer: Timer!
    
    var messageID = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        apiService = NetworkManager.shared.apiService
        
//        initInboxNavigationController()
//
//        if (Device.IS_IPAD) {
//            initSplitViewController()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let keyChainService = UtilityManager.shared.keychainService
        let isRememberMeEnabled = keyChainService.getRememberMeValue() 
        let twoFAstatus = keyChainService.getTwoFAstatus() 
        
        if (isRememberMeEnabled && (apiService?.canTokenRefresh() ?? false)) || (apiService?.isTokenValid() ?? false) {
            moveToNext()
        }else if isRememberMeEnabled && !twoFAstatus {
            let username = keyChainService.getUserName() 
            let password = keyChainService.getPassword() 
            authenticateUser(with: username, and: password)
        }else {
            showLoginViewController()
        }
    }
    
    func moveToNext() {
//        if (!Device.IS_IPAD) {
            showInboxNavigationController()
//        } else {
//            showSplitViewController()
//        }
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
        NotificationCenter.default.post(name: .updateInboxMessagesNotificationID, object: silent, userInfo: nil)
        print("sendUpdateNotification")
    }
    
    func showLoginViewController() {
        print("show login VC")
        DispatchQueue.main.async {
            let loginCoordinator = LoginCoordinator()
            loginCoordinator.showLogin(from: self, withSideMenu: self.getSlideMenuController())
        }
    }
    
    func showInboxNavigationController() {
        DispatchQueue.main.async {
            let slideMenuController = self.getSlideMenuController(with: self.messageID)
            slideMenuController.modalPresentationStyle = .fullScreen
            if let window = UIApplication.shared.getKeyWindow() {
                window.setRootViewController(slideMenuController)
            }else {
                self.show(slideMenuController, sender: self)
            }
        }
    }
}

//MARK: - SlideMenu Setup

extension MainViewController {
    func getSlideMenuController(with messageId: Int = -1) -> SlideMenuController {
        let inboxViewController = InboxViewController.instantiate(fromAppStoryboard: .Inbox)
        inboxViewController.messageID = messageId
        
        let inboxNavigationController = UIViewController.getNavController(rootViewController: inboxViewController)
        
        let leftMenuController = InboxSideMenuViewController.instantiate(fromAppStoryboard: .InboxSideMenu)
//        leftMenuController.mainViewController = self
        leftMenuController.inboxViewController = inboxViewController
        leftMenuController.dataSource?.selectedIndexPath = IndexPath(row: 0, section: SideMenuSectionIndex.mainFolders.rawValue)
        
        SlideMenuOptions.rightViewWidth = UIScreen.main.bounds.width / 1.3
        SlideMenuOptions.contentViewOpacity = 0.3
        SlideMenuOptions.panGesturesEnabled = false
        
        SlideMenuOptions.contentViewScale = 1
        
        let slideMenuController = SlideMenuController(mainViewController: inboxNavigationController, leftMenuViewController: leftMenuController)
        
        return slideMenuController
    }
}

//MARK: - SplitView Setup

extension MainViewController {
    func getSplitViewController(with messageId: Int = -1) -> SplitViewController{
        let splitViewController = SplitViewController.instantiate(fromAppStoryboard: .SplitiPad)
//        splitViewController.mainViewController = self
        
        let inboxViewController = InboxViewController.instantiate(fromAppStoryboard: .Inbox)
        inboxViewController.messageID = messageId
        
        let inboxNavigationController = UINavigationController(rootViewController: inboxViewController)
        
        splitViewController.showDetailViewController(inboxNavigationController, sender: self)
        
        return splitViewController
    }
    
    private func getSlideMenuController() -> SlideMenuController {
        let inboxViewController = InboxViewController.instantiate(fromAppStoryboard: .Inbox)
        let inboxNavigationController = UIViewController.getNavController(rootViewController: inboxViewController)
        
        let leftMenuController = InboxSideMenuViewController.instantiate(fromAppStoryboard: .InboxSideMenu)
        leftMenuController.inboxViewController = inboxViewController
        leftMenuController.dataSource?.selectedIndexPath = IndexPath(row: 0, section: SideMenuSectionIndex.mainFolders.rawValue)
        
        let slideMenuController = SlideMenuController(mainViewController: inboxNavigationController, leftMenuViewController: leftMenuController)
        SlideMenuOptions.rightViewWidth = UIScreen.main.bounds.width / 1.3
        SlideMenuOptions.contentViewOpacity = 0.3
        
        SlideMenuOptions.contentViewScale = 1
        
        return slideMenuController
    }
}

//MARK: - Authentication

extension MainViewController {
    func authenticateUser(with username: String, and password: String) {
        Loader.start()
        generateHashedPassword(for: username, password: password) { (result) in
            guard let value = try? result.get() else {
                Loader.stop()
                self.showLoginViewController()
                return
            }
            NetworkManager.shared.networkService.loginUser(with: LoginDetails(userName: username, password: value)) { (result) in
                Loader.stop()
                switch result {
                case .success(let value):
                    if let token = value.token {
                        UtilityManager.shared.keychainService.saveToken(token: token)
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




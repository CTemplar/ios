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
import SideMenu

class MainViewController: UIViewController, HashingService {
    var apiService: APIService?
    
    var mainTimer: Timer!
    
    var messageID = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        apiService = NetworkManager.shared.apiService
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
        showInboxNavigationController()
    }
    
    func setAutoUpdaterTimer() {
        DPrint("start AutoUpdaterTimer")
        mainTimer = Timer.scheduledTimer(timeInterval: 60,
                             target: self,
                             selector: #selector(self.sendUpdateNotification),
                             userInfo: nil,
                             repeats: true)
    }
    
    func stopAutoUpdaterTimer() {
        if mainTimer != nil {
            DPrint("stop AutoUpdaterTimer")
            mainTimer.invalidate()
            mainTimer = nil
        }
    }
    
    @objc func sendUpdateNotification() {
        let silent = true
        NotificationCenter.default.post(name: .updateInboxMessagesNotificationID, object: silent, userInfo: nil)
        DPrint("sendUpdateNotification")
    }
    
    func showLoginViewController() {
        DPrint("show login VC")
        DispatchQueue.main.async {
            let loginCoordinator = LoginCoordinator()
            loginCoordinator.showLogin(from: self, withSideMenu: self.sideMenu())
        }
    }
    
    func showInboxNavigationController() {
        DispatchQueue.main.async {
            let sideMenu = self.sideMenu(with: self.messageID)
            sideMenu.modalPresentationStyle = .fullScreen
            
            if let window = UIApplication.shared.getKeyWindow() {
                window.setRootViewController(sideMenu)
            } else {
                self.show(sideMenu, sender: self)
            }
        }
    }
}

//MARK: - SlideMenu Setup

extension MainViewController {
    func sideMenu(with messageId: Int = -1) -> SideMenuController {
        let inboxViewController = InboxViewController.instantiate(fromAppStoryboard: .Inbox)
        inboxViewController.messageID = messageId
        
        let inboxNavigationController = UIViewController.getNavController(rootViewController: inboxViewController)
        
        let leftMenuController = InboxSideMenuViewController.instantiate(fromAppStoryboard: .InboxSideMenu)
        leftMenuController.inboxViewController = inboxViewController
        leftMenuController.dataSource?.selectedIndexPath = IndexPath(row: 0, section: SideMenuSectionIndex.mainFolders.rawValue)

        let sideMenuController = SideMenuController(contentViewController: inboxNavigationController, menuViewController: leftMenuController)
        
        return sideMenuController
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




//
//  LoginInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 02.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import Networking
import UIKit

class LoginInteractor: HashingService {
    
    var viewController  : LoginViewController?
    var presenter       : LoginPresenter?
    var apiService      : APIService?
    var keychainService : KeychainService?
    
    func authenticateUser(userName: String, password: String, twoFAcode: String) {
        
        let trimmedUsername = trimUserName(userName)
        Loader.start()
        generateHashedPassword(for: trimmedUsername, password: password) { result in
            guard let value = try? result.get() else {
                Loader.stop()
                self.viewController?.showAlert(with: "Login Error".localized(),
                                               message: "Something went wrong".localized(),
                                               buttonTitle: Strings.Button.closeButton.localized)
                return
            }
            Loader.start()
            NetworkManager.shared.networkService.loginUser(with: LoginDetails(userName: trimmedUsername, password: value, twoFAcode: twoFAcode)) { result in
                self.handleNetwork(responce: result, username: userName, password: password)
                Loader.stop()
            }
        }
    }
    
    func handleNetwork(responce: AppResult<LoginResult>, username: String, password: String) {
        switch responce {
        case .success(let value):
            if value.isTwoFAEnabled {
                if value.token == nil {
                    viewController?.passwordBlockView.isHidden = true
                    viewController?.otpBlockView.isHidden = false
                    return
                }
            }
            if let token = value.token {
                keychainService?.saveToken(token: token)
            }
            if self.viewController?.rememberMeButton.isSelected ?? false {
                keychainService?.saveRememberMeValue(rememberMe: true)
            }else {
                keychainService?.saveRememberMeValue(rememberMe: false)
            }
            keychainService?.saveUserCredentials(userName: username, password: password)
            keychainService?.saveTwoFAvalue(isTwoFAenabled: value.isTwoFAEnabled)
            NotificationCenter.default.post(name: Notification.Name(k_updateInboxMessagesNotificationID), object: nil, userInfo: nil)
            self.sendAPNDeviceToken()
            self.viewController?.router?.showInboxScreen()
        case .failure(let error):
            self.viewController?.showAlert(with: "Login Error".localized(),
                                           message: error.localizedDescription,
                                           buttonTitle: Strings.Button.closeButton.localized)
            viewController?.passwordBlockView.isHidden = false
            viewController?.otpBlockView.isHidden = true
            viewController?.otpTextField.text = ""
        }
    }
    
    func trimUserName(_ userName: String) -> String {
        
        var trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let substrings = trimmedName.split(separator: "@")
            
        if let domain = substrings.last {
            if domain == k_mainDomain || domain == k_devMainDomain || domain == k_devOldDomain {
                if let name = substrings.first {
                    trimmedName = String(name)
                }
            }
        }
        
        return trimmedName
    }
    
    func sendAPNDeviceToken() {
        guard let deviceToken = keychainService?.getAPNDeviceToken(), !deviceToken.isEmpty  else { return }
        NetworkManager.shared.networkService.send(deviceToken: deviceToken) { _ in }
    }
}

extension LoginInteractor {
    func getSlideMenuController() -> SlideMenuController {
        let inboxViewController = InboxViewController.instantiate(fromAppStoryboard: .Inbox)
        
        let inboxNavigationController = (self.viewController?.getNavController(rootViewController: inboxViewController))!
        
        let leftMenuController = InboxSideMenuViewController.instantiate(fromAppStoryboard: .InboxSideMenu)
        leftMenuController.inboxViewController = inboxViewController
        leftMenuController.dataSource?.selectedIndexPath = IndexPath(row: 0, section: SideMenuSectionIndex.mainFolders.rawValue)
        
        let slideMenuController = SlideMenuController(mainViewController: inboxNavigationController, leftMenuViewController: leftMenuController)
        SlideMenuOptions.rightViewWidth = UIScreen.main.bounds.width / 1.3
        SlideMenuOptions.contentViewOpacity = 0.3
        
        SlideMenuOptions.contentViewScale = 1
        
        return slideMenuController
    }
    
    func getSplitViewController() -> SplitViewController{
        let splitViewController = SplitViewController.instantiate(fromAppStoryboard: .SplitiPad)
//        splitViewController.mainViewController = self.viewController!
        
        let inboxViewController = InboxViewController.instantiate(fromAppStoryboard: .Inbox)
        
        let inboxNavigationController = UINavigationController(rootViewController: inboxViewController)
        
        splitViewController.showDetailViewController(inboxNavigationController, sender: self)
        
        return splitViewController
    }
}

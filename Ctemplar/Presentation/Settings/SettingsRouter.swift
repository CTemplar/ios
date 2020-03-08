//
//  SettingsRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import SideMenu
import AlertHelperKit

class SettingsRouter {
    
    var viewController: SettingsViewController?

    func showInboxSideMenu() {
        
        //self.viewController?.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
        if (!Device.IS_IPAD) {
            self.viewController?.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
        } else {
            self.viewController?.splitViewController?.toggleMasterView()
        }
    }
    
    func showRecoveryEmailViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_RecoveryEmailStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_RecoveryEmailViewControllerID) as! RecoveryEmailViewController
        vc.user = (self.viewController?.user)!
        self.viewController?.show(vc, sender: self)
    }
    
    func showChangePasswordViewController() {
        //https://ctemplar.atlassian.net/browse/IAD-461
        AlertHelperKit().showAlert(viewController!, title: nil, message: "featureIsComing".localized(), button: "closeButton".localized())
        return
        
//        let storyboard: UIStoryboard = UIStoryboard(name: k_ChangePasswordStoryboardName, bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: k_ChangePasswordViewControllerID) as! ChangePasswordViewController
//        vc.user = (self.viewController?.user)!
//        self.viewController?.show(vc, sender: self)
    }
    
    func showSelectLanguageViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SelectLanguageStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_SelectLanguageViewControllerID) as! SelectLanguageViewController
        self.viewController?.show(vc, sender: self)
    }
    
    func showSavingContactsViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SavingContactsStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_SavingContactsViewControllerID) as! SavingContastsViewController
        vc.user = (self.viewController?.user)!
        self.viewController?.show(vc, sender: self)
    }
    
    func showSecurityViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SecurityStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_SecurityViewControllerID) as! SecurityViewController
        vc.user = (self.viewController?.user)!
        self.viewController?.show(vc, sender: self)
    }
    
    func showWhiteBlackListsViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_WhiteBlackListsStoryboardName, bundle: nil)
        /*
        let vc = storyboard.instantiateViewController(withIdentifier: k_WhiteBlackListsViewControllerID) as! WhiteBlackListsViewController
        vc.user = (self.viewController?.user)!
        let navigationController = UINavigationController(rootViewController: vc)
        self.viewController?.present(navigationController, animated: true, completion: nil)*/
        
        let navigationController = storyboard.instantiateViewController(withIdentifier: k_WhiteBlackListsNavigationControllerID) as! WhiteBlackListsNavigationController
        
        let whiteBlackListsViewController = navigationController.viewControllers.first as! WhiteBlackListsViewController
        whiteBlackListsViewController.user = (self.viewController?.user)!
        
        //self.viewController?.present(navigationController, animated: true, completion: nil)
        self.viewController?.show(whiteBlackListsViewController, sender: self)
    }
    
    func showManageFoldersViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ManageFoldersStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ManageFoldersViewControllerID) as! ManageFoldersViewController
        vc.foldersList = (self.viewController?.user.foldersList)!
        vc.user = (self.viewController?.user)!
        vc.showFromSideMenu = false
        vc.showFromSettings = true
        self.viewController?.show(vc, sender: self)
    }
    
    func showSetMailboxViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SetMailboxStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_SetMailboxViewControllerID) as! SetMailboxViewController
        vc.user = (self.viewController?.user)!
        self.viewController?.show(vc, sender: self)
    }
    
    func showSetSignatureViewController(with type: SignatureType) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SetSignatureStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_SetSignatureViewControllerID) as! SetSignatureViewController
        vc.signatureType = type
        vc.user = (self.viewController?.user)!
        self.viewController?.show(vc, sender: self)
    }
    
    func showPgpKeysViewController() {
        let storyboard: UIStoryboard = UIStoryboard(name: k_PGPKeysStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_PgpKeysViewControllerID) as! PgpKeysViewController
//        vc.user = (self.viewController?.user)!
        self.viewController?.show(vc, sender: self)
    }
    
    func showPrivacyAndTermsViewController(mode: TextControllerMode) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_PrivacyAndTermsStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_PrivacyAndTermsViewControllerID) as! PrivacyAndTermsViewController
        vc.mode = mode
        self.viewController?.show(vc, sender: self)
    }
    
    func showAboutAsViewController() {
        
        var storyboardName : String? = k_AboutAsStoryboardName
        
        if (Device.IS_IPAD) {
            storyboardName = k_AboutAsStoryboardName_iPad
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_AboutAsViewControllerID) as! AboutAsViewController       
        self.viewController?.show(vc, sender: self)
    }
}

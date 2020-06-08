//
//  AppStoryBoard.swift
//  Vision Collab
//
//  Created by Muhammad Asar on 24/02/2020.
//  Copyright © 2020 IMedHealth. All rights reserved.
//

import Foundation
import UIKit

enum AppStoryboard : String {
    
    case Main, Inbox, InboxSideMenu, LaunchScreen, Login, Login_iPad = "Login-iPad", Compose, Search, MoveTo, ViewInboxEmail, ManageFolders, AddFolder, EditFolder, Contacts, SplitiPad, Settings, RecoveryEmail, ChangePassword, SelectLanguage, SavingContacts, Security, WhiteBlackLists, SetMailbox, SetSignature, PgpKeys, PrivacyAndTerms, AboutAs, UpgradeToPrime, FAQ, Dashboard
    
    var instance : UIStoryboard {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let _ = Bundle.main.path(forResource: self.rawValue, ofType: "storyboardc") {
                return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
            }
        }
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T : UIViewController>(viewControllerClass : T.Type, function : String = #function, line : Int = #line, file : String = #file) -> T {
        
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
         
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        
        return instance.instantiateInitialViewController()
    }
}

extension UIViewController {
    
    // Not using static as it wont be possible to override to provide custom storyboardID then
    class var storyboardID : String {
        
        return "\(self)"
    }
    
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        
        return appStoryboard.viewController(viewControllerClass: self)
    }
}


//
//  AplicationManager.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class AppManager {
    static var shared = AppManager()
    let networkService = NetworkService()
    let keychainService = KeychainService()
    let formatterService = FormatterService()
    let restAPIService = RestAPIService()
    var myselfService: MyselfService?
    
    //let mainViewController: MainViewController = UIApplication.shared.keyWindow?.rootViewController as! MainViewController
    
    lazy var apiService: APIService = {
        
        let service = APIService()
        service.initialize()
        
        return service
        
    }()
    
    lazy var pgpService: PGPService = {
        
        let service = PGPService(keychainService: self.keychainService)
        
        return service
        
    }()
}

extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
    
    class func openAppSettings() {
        
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: {enabled in
            // ... handle if enabled
        })
    }
    
    class func openAppNotificationsSetting() {
        
        if let url = URL(string:"App-Prefs:root=NOTIFICATIONS_ID") {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}

extension Bundle {
    
    private static var bundle: Bundle!
    
    public static func localizedBundle() -> Bundle! {
        
        if bundle == nil {
            let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
            let path = Bundle.main.path(forResource: appLang, ofType: "lproj")
            bundle = Bundle(path: path!)
        }

        //print("bundlePath:", NSString(string: bundle.bundlePath).lastPathComponent)
        
        return bundle;
    }
    
    public static func setLanguage(lang: String) {
        
        print("set language:", lang)
        
        UserDefaults.standard.set(lang, forKey: "app_lang")
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        bundle = Bundle(path: path!)
    }
    
    public static func getLanguage() -> String {
        
        let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
        
        return appLang
    }
    
    public static func currentDeviceLanguageCode() -> String? {
        
        let locale = Locale.current.languageCode
        
        return locale
    }
    
    public static func currentAppLanguage() -> String? {
        
        let preferredLanguages = Locale.preferredLanguages[0]
        
        return preferredLanguages
    }
}

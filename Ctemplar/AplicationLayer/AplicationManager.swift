//
//  AplicationManager.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ApplicationManager
{
    
    //let mainViewController: MainViewController = UIApplication.shared.keyWindow?.rootViewController as! MainViewController
    
    lazy var apiService: APIService = {
        
        let service = APIService()
        service.initialize()
        
        return service
        
    }()
    
    lazy var formatterService: FormatterService = {
        
        let service = FormatterService()
        
        return service
        
    }()
    
    lazy var keychainService: KeychainService = {
        
        let service = KeychainService()
        
        return service
        
    }()
    
    lazy var pgpService: PGPService = {
        
        let service = PGPService()
        
        return service
        
    }()
    
    lazy var restAPIService: RestAPIService = {
        
        let service = RestAPIService()
        
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
}

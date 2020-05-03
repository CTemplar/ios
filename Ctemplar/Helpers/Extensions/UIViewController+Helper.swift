//
//  UIViewController+Helper.swift
//  Ctemplar
//
//  Created by Majid Hussain on 05/04/2020.
//  Copyright © 2020 AreteSol. All rights reserved.
//

import UIKit

extension UIViewController {
    func getNavController(rootViewController: UIViewController) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        let textAttributes = [NSAttributedString.Key.foregroundColor: k_navBar_titleColor]
        navController.navigationBar.titleTextAttributes = textAttributes
//        navController.navigationBar.backgroundColor = k_navBar_backgroundColor
        navController.navigationBar.barTintColor = k_navBar_backgroundColor
//        navController.navigationBar.isTranslucent = false
        
        return navController
    }
}

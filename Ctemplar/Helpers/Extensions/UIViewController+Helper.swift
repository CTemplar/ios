//
//  UIViewController+Helper.swift
//  Ctemplar
//
//  Created by Majid Hussain on 05/04/2020.
//  Copyright © 2020 CTemplar. All rights reserved.
//

import UIKit
import SwiftEntryKit

enum BannerConfig {
    case displayDuration(Double)
    case bannerColor(UIColor)
    case showButton(Bool)
}

extension UIViewController {
    func getNavController(rootViewController: UIViewController) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        let textAttributes = [NSAttributedString.Key.foregroundColor: k_navBar_titleColor]
        navController.navigationBar.titleTextAttributes = textAttributes
        navController.navigationBar.barTintColor = k_navBar_backgroundColor
        return navController
    }
    
    func showBanner(withTitle title: String,
                    closeButtonText: String = "closeButton".localized().capitalized,
                    additionalConfigs: [BannerConfig]) {
        
        var bannerColor = EKColor(k_folderCellTextColor)
        var displayDuration: Double = 3.0
        var showButton = false
        
        for config in additionalConfigs {
            switch config {
            case .bannerColor(let color):
                bannerColor = EKColor(color)
            case .displayDuration(let duration):
                displayDuration = duration
            case .showButton(let shouldShow):
                showButton = shouldShow
            }
        }
        
        var attributes = EKAttributes()
        attributes = .bottomNote
        attributes.displayMode = EKAttributes.DisplayMode.inferred
        attributes.displayDuration = displayDuration
        attributes.hapticFeedbackType = .success
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 6
            )
        )
        attributes.entryBackground = .color(color: bannerColor)
        attributes.statusBar = .dark
        
        let contentView = BannerView(with: [.titleText(title),
                                            .buttonTitle(closeButtonText),
                                            .showButton(showButton),
                                            .action({
                                                SwiftEntryKit.dismiss()
                                            })])
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    func showBannerAgain(withUpdatedText text: String,
                         closeButtonText: String = "closeButton".localized().capitalized,
                         additionalConfigs: [BannerConfig]) {
        SwiftEntryKit.dismiss(.displayed) {
            self.showBanner(withTitle: text,
                            closeButtonText: closeButtonText,
                            additionalConfigs: additionalConfigs)
        }
    }
}

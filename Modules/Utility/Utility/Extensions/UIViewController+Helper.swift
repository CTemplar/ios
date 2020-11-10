//
//  UIViewController+Helper.swift
//  CTemplar
//
//  Created by Majid Hussain on 05/04/2020.
//  Copyright © 2020 CTemplar. All rights reserved.
//

import UIKit
import SwiftEntryKit
import AlertHelperKit

public struct AlertKitParams {
    public private (set) var title: String?
    public private (set) var message: String?
    public private (set) var cancelButton: String?
    public private (set) var destructiveButtons: [String]?
    public private (set) var otherButtons: [String]?
    public private (set) var disabledButtons: [String]?
    public private (set) var inputFields: [InputField]?
    public private (set) var sender: AnyObject?
    public private (set) var arrowDirection: UIPopoverArrowDirection?
    public private (set) var popoverStyle: ActionSheetPopoverStyle = .normal
    
    public init(
        title: String? = nil,
        message: String? = nil,
        cancelButton: String? = nil,
        destructiveButtons: [String]? = nil,
        otherButtons: [String]? = nil,
        disabledButtons: [String]? = nil,
        inputFields: [InputField]? = nil,
        sender: AnyObject? = nil,
        arrowDirection: UIPopoverArrowDirection? = nil,
        popoverStyle: ActionSheetPopoverStyle = .normal
    ) {
        self.title = title
        self.message = message
        self.cancelButton = cancelButton
        self.destructiveButtons = destructiveButtons
        self.otherButtons = otherButtons
        self.disabledButtons = disabledButtons
        self.inputFields = inputFields
        self.sender = sender
        self.arrowDirection = arrowDirection
        self.popoverStyle = popoverStyle
    }
}

public enum BannerConfig {
    case displayDuration(Double)
    case bannerColor(UIColor)
    case showButton(Bool)
}

public extension UIViewController {
    static func getNavController(rootViewController: UIViewController,
                          navigationForegroundColor: UIColor = AppStyle.StringColor.navigationBarTitle.color,
                          navigationBarBackgroundColor: UIColor = AppStyle.StringColor.navigationBarBackground.color) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: navigationForegroundColor]
        
        navController.navigationBar.titleTextAttributes = textAttributes
        
        navController.navigationBar.barTintColor = navigationBarBackgroundColor
        
        navController.navigationBar.tintColor = AppStyle.Colors.loaderColor.color
                
        return navController
    }
    
    func showBanner(withTitle title: String,
                    closeButtonText: String = Strings.Button.closeButton.localized.capitalized,
                    additionalConfigs: [BannerConfig]) {
        
        var bannerColor = EKColor(AppStyle.StringColor.folderCellText.color)
        var displayDuration = 3.0
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
                         closeButtonText: String = Strings.Button.closeButton.localized.capitalized,
                         additionalConfigs: [BannerConfig]) {
        SwiftEntryKit.dismiss(.displayed) {
            self.showBanner(withTitle: text,
                            closeButtonText: closeButtonText,
                            additionalConfigs: additionalConfigs)
        }
    }
    
    func showAlert(with title: String,
                          message: String,
                          buttonTitle: String) {
        AlertHelperKit().showAlert(self,
                                   title: title,
                                   message: message,
                                   button: buttonTitle)
    }
    
    func showAlert(with params: AlertKitParams, onCompletion: @escaping (() -> Void)) {
        let parameters = Parameters(title: params.title, message: params.message, cancelButton: params.cancelButton, destructiveButtons: params.destructiveButtons, otherButtons: params.otherButtons, disabledButtons: params.disabledButtons, inputFields: params.inputFields, sender: params.sender, arrowDirection: params.arrowDirection, popoverStyle: params.popoverStyle)
        AlertHelperKit().showAlertWithHandler(self, parameters: parameters) { (_) in
            onCompletion()
        }
    }
    
    func showAlert(with params: AlertKitParams, onCompletion: @escaping ((Int) -> Void)) {
        let parameters = Parameters(title: params.title, message: params.message, cancelButton: params.cancelButton, destructiveButtons: params.destructiveButtons, otherButtons: params.otherButtons, disabledButtons: params.disabledButtons, inputFields: params.inputFields, sender: params.sender, arrowDirection: params.arrowDirection, popoverStyle: params.popoverStyle)
        AlertHelperKit().showAlertWithHandler(self, parameters: parameters) { (buttonIndex) in
            onCompletion(buttonIndex)
        }
    }
}

extension UIViewController: StoryboardIdentifiable {}

@nonobjc
public extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)

        if let frame = frame {
            child.view.frame = frame
        }

        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

//
//  ResetPasswordViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    var configurator: ForgotPasswordConfigurator?
    
    var resetCode       : String? = ""
    var userName        : String? = ""
    var recoveryEmail   : String? = ""
    
    @IBOutlet var recoveryEmailTextView  : UITextView!    
    @IBOutlet var resetCodeTextField     : UITextField!
    @IBOutlet var resetCodeHintLabel     : UILabel!
    
    var keyboardOffset = 0.0
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configurator = ForgotPasswordConfigurator()
        self.configurator?.configure(viewController: self)
        
        self.configurator?.presenter?.resetPasswordHintLabel(show: false)
        
        setupAttributesForTextView()
        
        if (Device.IS_IPHONE_5) {
            keyboardOffset = k_signUpPageKeyboardOffsetMedium
        } else {
            if Device.IS_IPAD {
                if UIDevice.current.orientation.isLandscape {
                    keyboardOffset = k_signUpPageKeyboardOffsetiPadBig
                } else {
                    keyboardOffset = 0.0
                }
            } else {
                keyboardOffset = 0.0
            }
        }
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
        
        adddNotificationObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.configurator?.presenter?.interactor?.recoveryPasswordCode(userName: userName!, recoveryEmail: recoveryEmail!)
    }
    
    func setupAttributesForTextView() {
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let attributedString = NSMutableAttributedString(string: "weHave".localized(), attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 14.0)!,
            .foregroundColor: k_lightGrayColor,
            .paragraphStyle: style,
            .kern: 0.0
            ])
        
        _ = attributedString.setUnderline(textToFind: "recoveryEmailAttr".localized())
        
        _ = attributedString.setForgroundColor(textToFind: "recoveryEmailAttr".localized(), color: k_urlColor)

        
        recoveryEmailTextView.attributedText = attributedString
        
        recoveryEmailTextView.disableTextPadding()
        if (!Device.IS_IPAD) {
            recoveryEmailTextView.autosizeTextFont()
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPasswordButtonPressed(_ sender: AnyObject) {
        
        self.configurator?.presenter?.buttonResetPasswordPressed(userName: userName!, resetCode: resetCode!, recoveryEmail: recoveryEmail!)
    }
    
    @IBAction func resetCodeTyped(_ sender: UITextField) {
        
        resetCode = sender.text
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.configurator?.presenter?.resetPasswordHintLabel(show: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.configurator?.presenter?.resetPasswordHintLabel(show: false)
    }
    
    //MARK: - notification
    
    func adddNotificationObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= CGFloat(keyboardOffset)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += CGFloat(keyboardOffset)
        }
    }
    
    //MARK: - Orientation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if (Device.IS_IPAD) {
            
            self.view.endEditing(true)
            
            if UIDevice.current.orientation.isLandscape {
                keyboardOffset = k_signUpPageKeyboardOffsetiPadBig
            } else {
                keyboardOffset = 0.0
            }
        }
    }
}

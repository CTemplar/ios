//
//  ResetPasswordViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

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
        
        self.configurator?.presenter?.setupResetCodeTextFieldsAndHintLabel(resetCode: resetCode!)
        
        setupAttributesForTextView()
        
        if (Device.IS_IPHONE_5) {
            keyboardOffset = k_signUpPageKeyboardOffsetMedium
        } else {
            keyboardOffset = 0.0
        }
        
        adddNotificationObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.configurator?.presenter?.interactor?.recoveryPasswordCode(userName: userName!, recoveryEmail: recoveryEmail!)
    }
    
    func setupAttributesForTextView() {
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let attributedString = NSMutableAttributedString(string: "We have sent a reset code to your\nrecovery email to reset your password. ", attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 14.0)!,
            .foregroundColor: k_lightGrayColor,
            .paragraphStyle: style,
            .kern: 0.0
            ])
        
        _ = attributedString.setUnderline(textToFind: "recovery email ")
        
        _ = attributedString.setForgroundColor(textToFind: "recovery email ", color: k_urlColor)

        
        recoveryEmailTextView.attributedText = attributedString
        
        recoveryEmailTextView.disableTextPadding()
        recoveryEmailTextView.autosizeTextFont()
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPasswordButtonPressed(_ sender: AnyObject) {
        
        //self.configurator?.presenter?.buttonResetPasswordPressed(userName: userName!, resetCode: resetCode!, recoveryEmail: recoveryEmail!)
        
        //temp     
        self.configurator?.router?.showNewPasswordViewController(userName: userName!, resetPasswordCode: resetCode!, recoveryEmail: recoveryEmail!)
        
    }
    
    @IBAction func resetCodeTyped(_ sender: UITextField) {
        
        resetCode = sender.text
        self.configurator?.presenter?.setupResetCodeTextFieldsAndHintLabel(resetCode: resetCode!)
    }
    
    //MARK: - notification
    
    func adddNotificationObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpPageNameViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpPageNameViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
}

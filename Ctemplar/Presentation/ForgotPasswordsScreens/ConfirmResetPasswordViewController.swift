//
//  ConfirmResetPasswordViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ConfirmResetPasswordViewController: UIViewController {
    
    var configurator: ForgotPasswordConfigurator?
    
    @IBOutlet var confirmTextView          : UITextView!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configurator = ForgotPasswordConfigurator()
        self.configurator?.configure(viewController: self)
        
        setupAttributesForTextView()
    }
    
    func setupAttributesForTextView() {
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let attributedString = NSMutableAttributedString(string: "Your encryption key is connected to your password. Because of this you will not be able to decrypt old messages, attachments and contacts if you reset your password. Click here to learn more. \nIf you have further questions please email support@ctemplar.com.", attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 14.0)!,
            .foregroundColor: k_lightGrayColor,
            .paragraphStyle: style,
            .kern: 0.0
            ])
        
        _ = attributedString.setAsLink(textToFind: "Click here to learn more", linkURL: k_termsURL)
        
        _ = attributedString.setUnderline(textToFind: "Click here to learn more")
        _ = attributedString.setUnderline(textToFind: "support@ctemplar.com")
        
        _ = attributedString.setForgroundColor(textToFind: "you will not be able to decrypt old messages, attachments and contacts", color: k_redColor)
        _ = attributedString.setForgroundColor(textToFind: "Click here to learn more", color: k_urlColor)
        _ = attributedString.setForgroundColor(textToFind: "support@ctemplar.com", color: k_urlColor)
        
        confirmTextView.attributedText = attributedString
        
        confirmTextView.disableTextPadding()
        confirmTextView.autosizeTextFont()
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: AnyObject) {
        
        self.configurator?.router?.showResetPasswordViewController()       
    }
}

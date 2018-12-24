//
//  RecoveryEmailViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 24.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class RecoveryEmailViewController: UIViewController {
    
    @IBOutlet var rightBarButtonItem       : UIBarButtonItem!
    @IBOutlet var textFieldView            : UIView!
    @IBOutlet var inputTextField           : UITextField!
    @IBOutlet var switcher                 : UISwitch!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var recoveryEmail : String = ""
    
    var user = UserMyself()
    
    var formatterService        : FormatterService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.formatterService = appDelegate.applicationManager.formatterService
        
        self.setupScreen()
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textTyped(_ sender: UITextField) {
        
        self.recoveryEmail = sender.text!
        self.rigthBarButtonEnabled()
    }
    
    @IBAction func switchStateDidChange(_ sender:UISwitch) {
    
        if (sender.isOn == true) {
            self.textFieldView.isHidden = false
            self.setupRightBarButton(show: true)
            self.rigthBarButtonEnabled()
        } else {
            self.textFieldView.isHidden = true
            self.setupRightBarButton(show: false)
        }
    }
    
    func setupScreen() {
        
        if let recoveryEmail = user.settings.recoveryEmail {
            if recoveryEmail.count > 0 {
                self.recoveryEmail = recoveryEmail
                self.textFieldView.isHidden = false
                self.inputTextField.text = recoveryEmail
                self.switcher.setOn(true, animated: false)
                self.setupRightBarButton(show: true)
            } else {
                self.textFieldView.isHidden = true
                self.switcher.setOn(false, animated: false)
                self.setupRightBarButton(show: false)
            }
        } else {
            self.textFieldView.isHidden = true
            self.switcher.setOn(false, animated: false)
            self.setupRightBarButton(show: false)
        }
    }
    
    func setupRightBarButton(show: Bool) {
                
        if show {
            let cancelItem = UIBarButtonItem(title: "saveButton".localized(), style: .plain, target: self, action: #selector(cancelButtonPressed))
            
            cancelItem.tintColor = UIColor.darkGray
            self.navigationItem.rightBarButtonItem = cancelItem
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func rigthBarButtonEnabled() {
        
        if self.validateEmail(email: self.recoveryEmail) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func validateEmail(email: String) -> Bool {
     
        if (self.formatterService?.validateEmailFormat(enteredEmail: email))! {
            return true
        }
        
        return false
    }
}

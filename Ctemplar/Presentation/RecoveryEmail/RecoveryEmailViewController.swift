//
//  RecoveryEmailViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 24.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import AlertHelperKit
import PKHUD

class RecoveryEmailViewController: UIViewController {
    
    @IBOutlet var rightBarButtonItem       : UIBarButtonItem!
    @IBOutlet var textFieldView            : UIView!
    @IBOutlet var inputTextField           : UITextField!
    @IBOutlet var switcher                 : UISwitch!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var recoveryEmail : String = ""
    var apiService      : APIService?
    
    var user = UserMyself()
    
    var formatterService        : FormatterService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.formatterService = appDelegate.applicationManager.formatterService        
        self.apiService = appDelegate.applicationManager.apiService
        
        self.setupScreen()
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        
        self.updateRecoveryEmail(settings: self.user.settings, recoveryEmail: self.recoveryEmail)
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
            self.setupRightBarButton(show: true)
            self.recoveryEmail = " " //if use just "" mail is not updated
        }
    }
    
    func setupScreen() {
        
        //self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: k_contactsBarTintColor]
        
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
            let saveItem = UIBarButtonItem(title: "saveButton".localized(), style: .plain, target: self, action: #selector(saveButtonPressed))
            saveItem.tintColor = UIColor.darkGray
            self.navigationItem.rightBarButtonItem = saveItem
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
    
    func updateRecoveryEmail(settings: Settings, recoveryEmail: String) {
        
        let settingsID = settings.settingsID
        let savingContacts = settings.saveContacts
        
        apiService?.updateSettings(settingsID: (settingsID?.description)!, recoveryEmail: recoveryEmail, dispalyName: "", savingContacts: savingContacts!) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("updateRecoveryEmail value:", value)
                self.postUpdateUserSettingsNotification()
                self.recoveryEmailWasUpdated()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self, title: "Update Settings Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func postUpdateUserSettingsNotification() {
        
        NotificationCenter.default.post(name: Notification.Name(k_updateUserSettingsNotificationID), object: nil, userInfo: nil)
    }
    
    func recoveryEmailWasUpdated() {
        
        let params = Parameters(
            title: "infoTitle".localized(),
            message: "recoveryEmailUpdatedMessage".localized(),
            cancelButton: "closeButton".localized()
        )
        
        AlertHelperKit().showAlertWithHandler(self, parameters: params) { buttonIndex in
            
            //self.dismiss(animated: true, completion: nil)
            self.cancelButtonPressed(self)
        }
    }
}

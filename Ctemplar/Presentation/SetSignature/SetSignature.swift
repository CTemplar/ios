//
//  SetSignature.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 25.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import AlertHelperKit
import PKHUD

class SetSignatureViewController: UIViewController {
    
    @IBOutlet var rightBarButtonItem       : UIBarButtonItem!
    @IBOutlet var textFieldView            : UIView!
    @IBOutlet var inputTextField           : UITextField!
    @IBOutlet var switcher                 : UISwitch!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var userSignature : String = ""
    var apiService      : APIService?
    
    var user = UserMyself()
    var mailbox = Mailbox()
    
    var formatterService        : FormatterService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.formatterService = appDelegate.applicationManager.formatterService
        self.apiService = appDelegate.applicationManager.apiService
        
        self.mailbox = (self.apiService?.defaultMailbox(mailboxes: self.user.mailboxesList!))!
        
        self.setupScreen()
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        
        self.updateUserSignature(mailbox: self.mailbox, userSignature: self.userSignature)
    }
    
    @IBAction func textTyped(_ sender: UITextField) {
        
        self.userSignature = sender.text!
        self.rigthBarButtonEnabled()
    }
    
    @IBAction func switchStateDidChange(_ sender:UISwitch) {
        
        if (sender.isOn == true) {
            self.textFieldView.isHidden = false
            self.userSignature = self.inputTextField.text!
            self.setupRightBarButton(show: true)
            self.rigthBarButtonEnabled()
        } else {
            self.textFieldView.isHidden = true
            if let signature = self.mailbox.signature {
                if signature.count > 0 {
                    self.userSignature = " "
                } else {
                    self.setupRightBarButton(show: false)
                }
            }
        }
    }
    
    func setupScreen() {
        
        //self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: k_contactsBarTintColor]
       
        if let signature = self.mailbox.signature {
            if signature.count > 0 {
                self.userSignature = signature
                self.textFieldView.isHidden = false
                self.inputTextField.text = signature
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
        
        if self.validateUserSignature(email: self.userSignature) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func validateUserSignature(email: String) -> Bool {
        
        if (self.formatterService?.validateNameLench(enteredName: email))! {
            return true
        }
        
        return false
    }
    
    func updateUserSignature(mailbox: Mailbox, userSignature: String) {
        
        let mailboxID = mailbox.mailboxID?.description
        let isDefault = mailbox.isDefault
        
        apiService?.updateMailbox(mailboxID: mailboxID!, userSignature: userSignature, displayName: "", isDefault: isDefault!) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("updateUserSignature value:", value)
                self.postUpdateUserSettingsNotification()                
                self.userSignatureWasUpdated()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self, title: "Update Settings Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func postUpdateUserSettingsNotification() {
        
        NotificationCenter.default.post(name: Notification.Name(k_updateUserSettingsNotificationID), object: nil, userInfo: nil)
    }
    
    func userSignatureWasUpdated() {
        
        let params = Parameters(
            title: "infoTitle".localized(),
            message: "userSignature".localized(),
            cancelButton: "closeButton".localized()
        )
        
        AlertHelperKit().showAlertWithHandler(self, parameters: params) { buttonIndex in
            
            self.cancelButtonPressed(self)
        }
    }
}

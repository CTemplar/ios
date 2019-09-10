//
//  SecurityViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 06.09.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import AlertHelperKit
import PKHUD

class SecurityViewController: UIViewController {
    
    @IBOutlet var switcher                 : UISwitch!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var apiService              : APIService?
    var formatterService        : FormatterService?
    
    var user = UserMyself()
    
    var encryptContacts : Bool = false
    
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
    
    func setupScreen() {
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: k_contactsBarTintColor]
        
        self.encryptContacts = self.user.settings.isContactsEncrypted ?? false
        
        self.switcher.setOn(self.encryptContacts, animated: true)
    }
    
    @IBAction func switchStateDidChange(_ sender: UISwitch) {
        
        if (sender.isOn == true) {
            self.encryptContacts = true
        } else {
            self.encryptContacts = false
        }
        
        self.showWarningPopUp(settings: self.user.settings, encryptContacts: self.encryptContacts)
    }
    
    func showWarningPopUp(settings: Settings, encryptContacts: Bool) {
        
        var encryptButtonText = ""
        var encryptTitleText = ""
        var encryptMessageText = ""
        
        if encryptContacts {
            encryptButtonText = "encryptButton".localized()
            encryptTitleText = "encryptContactsTitle".localized()
            encryptMessageText = "encryptContacts".localized()
        } else {
            encryptButtonText = "decryptButton".localized()
            encryptTitleText = "decryptContactsTitle".localized()
            encryptMessageText = "decryptContacts".localized()
        }
        
        let params = Parameters(
            title: encryptTitleText,
            message: encryptMessageText,
            cancelButton: "cancelButton".localized(),
            otherButtons: [encryptButtonText]
        )
        
        AlertHelperKit().showAlertWithHandler(self, parameters: params) { buttonIndex in
            switch buttonIndex {
            case 0:
                break
            default:
                print("Change Contact Encryption")
                self.updateEncriptionContacts(settings: settings, encryptContacts: encryptContacts)
            }
        }
        
    }    
    
    func updateEncriptionContacts(settings: Settings, encryptContacts: Bool) {
        
        let settingsID = settings.settingsID
        
        apiService?.updateSettings(settingsID: (settingsID?.description)!, recoveryEmail: "", dispalyName: "", savingContacts: settings.saveContacts ?? false, encryptContacts: encryptContacts) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("updateEncriptionContacts value:", value)
                self.postUpdateUserSettingsNotification()
                
            case .failure(let error):
                print("error:", error)
                self.switcher.setOn(!encryptContacts, animated: true)
                AlertHelperKit().showAlert(self, title: "Update Settings Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func postUpdateUserSettingsNotification() {
        
        NotificationCenter.default.post(name: Notification.Name(k_updateUserSettingsNotificationID), object: nil, userInfo: nil)
    }
}

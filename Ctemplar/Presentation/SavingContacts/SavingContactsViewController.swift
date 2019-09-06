//
//  SavingContactsViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 26.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import AlertHelperKit
import PKHUD

class SavingContastsViewController: UIViewController {
    
    @IBOutlet var switcher                 : UISwitch!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var apiService              : APIService?
    var formatterService        : FormatterService?
    
    var user = UserMyself()
    
    var saveContacts : Bool = false
    
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
        
        self.saveContacts = self.user.settings.saveContacts!
        
        self.switcher.setOn(self.saveContacts, animated: true)
    }
    
    @IBAction func switchStateDidChange(_ sender:UISwitch) {
        
        if (sender.isOn == true) {
            self.saveContacts = true
        } else {
            self.saveContacts = false
        }
        
        self.updateSavingContacts(settings: self.user.settings, savingContacts: self.saveContacts)
    }
    
    func updateSavingContacts(settings: Settings, savingContacts: Bool) {
        
        let settingsID = settings.settingsID
        
        apiService?.updateSettings(settingsID: (settingsID?.description)!, recoveryEmail: "", dispalyName: "", savingContacts: savingContacts, encryptContacts: settings.isContactsEncrypted ?? false) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("updateSavingContacts value:", value)
                self.postUpdateUserSettingsNotification()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self, title: "Update Settings Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func postUpdateUserSettingsNotification() {
        
        NotificationCenter.default.post(name: Notification.Name(k_updateUserSettingsNotificationID), object: nil, userInfo: nil)
    }
}

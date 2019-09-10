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
                self.encryptContacts = !self.encryptContacts
                self.switcher.setOn(self.encryptContacts, animated: true)
                break
            default:
                print("Change Contact Encryption")
                //if encryptContacts {
                    self.updateEncryptionContacts(settings: settings, encryptContacts: encryptContacts)
               // } else {
               //     self.startDecryption()
               // }
            }
        }
        
    }    
    
    func updateEncryptionContacts(settings: Settings, encryptContacts: Bool) {
        
        HUD.show(.progress)
        
        let settingsID = settings.settingsID
        
        apiService?.updateSettings(settingsID: (settingsID?.description)!, recoveryEmail: "", dispalyName: "", savingContacts: settings.saveContacts ?? false, encryptContacts: encryptContacts) {(result) in
            
            HUD.hide()
            
            switch(result) {
                
            case .success(let value):
                print("updateEncryptionContacts value:", value)
                if encryptContacts {
                    self.postUpdateUserSettingsNotification()
                    AlertHelperKit().showAlert(self, title: "Info:".localized(), message: "allContactsWasEncrypted".localized(), button: "closeButton".localized())
                } else {
                    self.startDecryption()
                }
            case .failure(let error):
                print("error:", error)
                self.encryptContacts = !self.encryptContacts
                self.switcher.setOn(self.encryptContacts, animated: true)
                AlertHelperKit().showAlert(self, title: "Update Settings Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func postUpdateUserSettingsNotification() {
        
        NotificationCenter.default.post(name: Notification.Name(k_updateUserSettingsNotificationID), object: nil, userInfo: nil)
    }
    
    func startDecryption() {
        
        HUD.show(.labeledProgress(title: "decryptingContacts".localized(), subtitle: ""))
        
        self.userContactsList()
    }
    
    func decryptContacts(contacts: Array<Contact> ) {
        
        var decryptedContacts = 0
        
        for contact in contacts {
            self.decryptContact(contact) { done in
                if done {
                    decryptedContacts = decryptedContacts + 1
                } else {
                    //something went wrong
                    AlertHelperKit().showAlert(self, title: "Error:", message: "Contact Encryption Error", button: "closeButton".localized())
                    self.encryptContacts = true
                    self.switcher.setOn(self.encryptContacts, animated: true)
                    HUD.hide()
                }
                
                if decryptedContacts == contacts.count {
                    HUD.hide()
                    AlertHelperKit().showAlert(self, title: "Info:".localized(), message: "allContactsWasDecrypted".localized(), button: "closeButton".localized())
                }
            }
        }
    }
    
    func decryptContact(_ contact: Contact, with completion: ((_ done: Bool) -> Void)? = nil) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let pgpService = appDelegate.applicationManager.pgpService
        
        if let encryptedData = contact.encryptedData {
            let decryptedContent = pgpService.decryptMessage(encryptedContet: encryptedData)
            let dictionary = self.convertStringToDictionary(text: decryptedContent)
            let decryptedContact = Contact(decryptedDictionary: dictionary, contactId: contact.contactID ?? 0)
            
            self.updateContact(contactID: contact.contactID?.description ?? "", name: decryptedContact.contactName ?? "name", email:  decryptedContact.email ?? "emal", phone: decryptedContact.phone ?? "", address: decryptedContact.address ?? "", note: decryptedContact.note ?? "") { done in
                completion?(done)
            }
        }
    }
    
    func convertStringToDictionary(text: String) -> [String:Any] {
        
        var dicitionary = [String:Any]()
        
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    // print("convertStringToDictionary:", json as Any)
                    dicitionary = json
                }
                return dicitionary
                
            } catch {
                print("convertStringToDictionary: Something went wrong string ->", text)
                return dicitionary
            }
        }
        
        return dicitionary
    }
    
    func userContactsList() {
        
        apiService?.userContacts(fetchAll: true, offset: 0, silent: true) {(result) in
            
            switch(result) {
                
            case .success(let value):
                
                let contactsList = value as! ContactsList
                if let contacts = contactsList.contactsList {
                    self.decryptContacts(contacts: contacts)
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self, title: "Contacts Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func updateContact(contactID: String, name: String, email: String, phone: String, address: String, note: String, with completion: ((_ done: Bool) -> Void)? = nil) {
        
        print("email:", email)
        
        apiService?.updateContact(contactID: contactID, name: name, email: email, phone: phone, address: address, note: note) {(result) in
                
            switch(result) {
                    
            case .success(let value):
                print("updateContact:", value)
                completion?(true)
            case .failure(let error):
                print("error:", error)
                completion?(false)
                //AlertHelperKit().showAlert(self, title: "Contacts Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}

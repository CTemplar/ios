//
//  SecurityInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17/09/2019.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class SecurityInteractor {
    
    var viewController  : SecurityViewController?
    var apiService      : APIService?
    
    func updateEncryptionSubject(settings: Settings, encryptSubject: Bool, encryptContacts: Bool, encryptAttachment: Bool) {
        HUD.show(.progress)
        
        let settingsID = settings.settingsID ?? 0
        apiService?.updateSettings(settingsID: settingsID, recoveryEmail: "", dispalyName: "", savingContacts: settings.saveContacts ?? false, encryptContacts: encryptContacts, encryptAttachment: encryptAttachment, encryptSubject: encryptSubject) {(result) in
        
            HUD.hide()
            
            switch(result) {
            case .success(_):
                self.postUpdateUserSettingsNotification()
                break
            case .failure(let error):
                self.viewController!.encryptSubject = !self.viewController!.encryptSubject
                self.viewController!.subjectEncryptionSwitch.setOn(self.viewController!.encryptSubject, animated: true)
                AlertHelperKit().showAlert(self.viewController!, title: "Update Settings Error", message: error.localizedDescription, button: "closeButton".localized())
                break
            }
        }
    }

    func updateEncryptionContacts(settings: Settings, encryptSubject: Bool, encryptContacts: Bool, encryptAttachment: Bool) {
        
        HUD.show(.progress)
        
        let settingsID: Int = settings.settingsID ?? 0
        
        apiService?.updateSettings(settingsID: settingsID, recoveryEmail: "", dispalyName: "", savingContacts: settings.saveContacts ?? false, encryptContacts: encryptContacts, encryptAttachment: encryptAttachment, encryptSubject: encryptSubject) {(result) in
            
            HUD.hide()
            
            switch(result) {
                
            case .success(let value):
                print("updateEncryptionContacts value:", value)
                if encryptContacts {
                    self.postUpdateUserSettingsNotification()
                    AlertHelperKit().showAlert(self.viewController!, title: "Info:".localized(), message: "allContactsWasEncrypted".localized(), button: "closeButton".localized())
                } else {
                    self.startDecryption()
                }
            case .failure(let error):
                print("error:", error)
                self.viewController!.encryptContacts = !self.viewController!.encryptContacts
                self.viewController!.contactsEncryptionSwitcher.setOn(self.viewController!.encryptContacts, animated: true)
                AlertHelperKit().showAlert(self.viewController!, title: "Update Settings Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
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
                    AlertHelperKit().showAlert(self.viewController!, title: "Error:", message: "Contact Encryption Error", button: "closeButton".localized())
                    self.viewController!.encryptContacts = true
                    self.viewController!.contactsEncryptionSwitcher.setOn(self.viewController!.encryptContacts, animated: true)
                    HUD.hide()
                }
                
                if decryptedContacts == contacts.count {
                    HUD.hide()
                    self.postUpdateUserSettingsNotification()
                    AlertHelperKit().showAlert(self.viewController!, title: "Info:".localized(), message: "allContactsWasDecrypted".localized(), button: "closeButton".localized())
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
                AlertHelperKit().showAlert(self.viewController!, title: "Contacts Error", message: error.localizedDescription, button: "closeButton".localized())
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
    
    func updateEncryptionAttachment(settings: Settings, encryptSubject: Bool, encryptContacts: Bool, encryptAttachment: Bool) {
        
        HUD.show(.progress)
        
        let settingsID = settings.settingsID ?? 0
        
        apiService?.updateSettings(settingsID: settingsID, recoveryEmail: "", dispalyName: "", savingContacts: settings.saveContacts ?? false, encryptContacts: encryptContacts, encryptAttachment: encryptAttachment, encryptSubject: encryptSubject) {(result) in
            
            HUD.hide()
            
            switch(result) {
                
            case .success(let value):
                print("updateEncryptionAttachment value:", value)
                
                if encryptAttachment {
                    AlertHelperKit().showAlert(self.viewController!, title: "Info:".localized(), message: "attachmentEncryptionWasEnabled".localized(), button: "closeButton".localized())
                } else {
                    AlertHelperKit().showAlert(self.viewController!, title: "Info:".localized(), message: "attachmentEncryptionWasDisabled".localized(), button: "closeButton".localized())
                }
                
                self.postUpdateUserSettingsNotification()
                
            case .failure(let error):
                print("error:", error)
                self.viewController!.encryptAttachment = !self.viewController!.encryptAttachment
                self.viewController!.attachmentEncryptionSwitcher.setOn(self.viewController!.encryptAttachment, animated: true)
                AlertHelperKit().showAlert(self.viewController!, title: "Update Settings Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func postUpdateUserSettingsNotification() {
        
        NotificationCenter.default.post(name: Notification.Name(k_updateUserSettingsNotificationID), object: nil, userInfo: nil)
    }
}

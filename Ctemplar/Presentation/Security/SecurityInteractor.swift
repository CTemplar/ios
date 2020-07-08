//
//  SecurityInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17/09/2019.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Foundation
import Utility
import Networking

class SecurityInteractor {
    
    var viewController  : SecurityViewController?
    var apiService      : APIService?
    
    func updateEncryptionSubject(settings: Settings, encryptSubject: Bool, encryptContacts: Bool, encryptAttachment: Bool) {
        Loader.start()
        
        let settingsID = settings.settingsID ?? 0
        apiService?.updateSettings(settingsID: settingsID, recoveryEmail: "", dispalyName: "", savingContacts: settings.saveContacts ?? false, encryptContacts: encryptContacts, encryptAttachment: encryptAttachment, encryptSubject: encryptSubject) {(result) in
        
            Loader.stop()
            
            switch(result) {
            case .success(_):
                self.postUpdateUserSettingsNotification()
            case .failure(let error):
                self.viewController!.encryptSubject = !self.viewController!.encryptSubject
                self.viewController!.subjectEncryptionSwitch.setOn(self.viewController!.encryptSubject, animated: true)
                self.viewController?.showAlert(with: "Update Settings Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
            }
        }
    }

    func updateEncryptionContacts(settings: Settings, encryptSubject: Bool, encryptContacts: Bool, encryptAttachment: Bool) {
        
        Loader.start()
        
        let settingsID: Int = settings.settingsID ?? 0
        
        apiService?.updateSettings(settingsID: settingsID, recoveryEmail: "", dispalyName: "", savingContacts: settings.saveContacts ?? false, encryptContacts: encryptContacts, encryptAttachment: encryptAttachment, encryptSubject: encryptSubject) {(result) in
            
            Loader.stop()
            
            switch(result) {
                
            case .success(let value):
                print("updateEncryptionContacts value:", value)
                if encryptContacts {
                    self.postUpdateUserSettingsNotification()
                    self.viewController?.showAlert(with: "Info:".localized(), message: "allContactsWasEncrypted".localized(), buttonTitle: Strings.Button.closeButton.localized)
                } else {
                    self.startDecryption()
                }
            case .failure(let error):
                print("error:", error)
                self.viewController!.encryptContacts = !self.viewController!.encryptContacts
                self.viewController!.contactsEncryptionSwitcher.setOn(self.viewController!.encryptContacts, animated: true)
                self.viewController?.showAlert(with: "Update Settings Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
            }
        }
    }
    
    func startDecryption() {
        Loader.start()
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
                    self.viewController?.showAlert(with: "Error", message: "Contact Encryption Error", buttonTitle: Strings.Button.closeButton.localized)
                    self.viewController!.encryptContacts = true
                    self.viewController!.contactsEncryptionSwitcher.setOn(self.viewController!.encryptContacts, animated: true)
                    Loader.stop()
                }
                
                if decryptedContacts == contacts.count {
                    Loader.stop()
                    self.postUpdateUserSettingsNotification()
                    
                    self.viewController?.showAlert(with: "Info:".localized(), message: "allContactsWasDecrypted".localized(), buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }
    
    func decryptContact(_ contact: Contact, with completion: ((_ done: Bool) -> Void)? = nil) {        
        let pgpService = UtilityManager.shared.pgpService
        
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
                self.viewController?.showAlert(with: "Contacts Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
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
            }
        }
    }
    
    func updateEncryptionAttachment(settings: Settings, encryptSubject: Bool, encryptContacts: Bool, encryptAttachment: Bool) {
        
        Loader.start()
        
        let settingsID = settings.settingsID ?? 0
        
        apiService?.updateSettings(settingsID: settingsID, recoveryEmail: "", dispalyName: "", savingContacts: settings.saveContacts ?? false, encryptContacts: encryptContacts, encryptAttachment: encryptAttachment, encryptSubject: encryptSubject) {(result) in
            
            Loader.stop()
            
            switch(result) {
                
            case .success(let value):
                print("updateEncryptionAttachment value:", value)
                
                if encryptAttachment {
                    self.viewController?.showAlert(with: "Info:".localized(), message: "attachmentEncryptionWasEnabled".localized(), buttonTitle: Strings.Button.closeButton.localized)
                } else {
                    self.viewController?.showAlert(with: "Info:".localized(), message: "attachmentEncryptionWasDisabled".localized(), buttonTitle: Strings.Button.closeButton.localized)
                }
                
                self.postUpdateUserSettingsNotification()
                
            case .failure(let error):
                print("error:", error)
                self.viewController!.encryptAttachment = !self.viewController!.encryptAttachment
                self.viewController!.attachmentEncryptionSwitcher.setOn(self.viewController!.encryptAttachment, animated: true)
                self.viewController?.showAlert(with: "Update Settings Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
            }
        }
    }
    
    func postUpdateUserSettingsNotification() {
        
        NotificationCenter.default.post(name: .updateUserSettingsNotificationID, object: nil, userInfo: nil)
    }
}

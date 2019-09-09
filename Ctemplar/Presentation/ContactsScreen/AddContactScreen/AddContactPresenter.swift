//
//  AddContactPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class AddContactPresenter {
    
    var viewController   : AddContactViewController?
    var interactor       : AddContactInteractor?
    var formatterService : FormatterService?

    func setInputs(sender: UITextField) {
        
        switch sender {
        case (self.viewController?.contactNameTextField)!:
            print("contactNameTextField typed:", sender.text!)
            self.viewController?.contactName = sender.text
        case (self.viewController?.contactEmailTextField)!:
            print("contactEmailTextField typed:", sender.text!)
             self.viewController?.contactEmail = sender.text
        case (self.viewController?.contactPhoneTextField)!:
            print("contactPhoneTextField typed:", sender.text!)
            self.viewController?.contactPhone = sender.text
        case (self.viewController?.contactAddressTextField)!:
            print("contactAddressTextField typed:", sender.text!)
            self.viewController?.contactAddress = sender.text
        case (self.viewController?.contactNoteTextField)!:
            print("contactAddressTextField typed:", sender.text!)
            self.viewController?.contactNote = sender.text
        default:
            print("unknown textfield")
        }
        
        self.setupSaveButton(contactName: (self.viewController?.contactName)!, contactEmail: (self.viewController?.contactEmail)!)
    }
    
    func setEditContact(contact: Contact) {
        
        if let name = contact.contactName {
            self.viewController?.contactName = name
            self.viewController?.contactNameTextField.text = name
        }
        
        if let email = contact.email {
            self.viewController?.contactEmail = email
            self.viewController?.contactEmailTextField.text = email
        }
        
        if let phone = contact.phone {
            self.viewController?.contactPhone = phone
            self.viewController?.contactPhoneTextField.text = phone
        }
     
        if let address = contact.address {
            self.viewController?.contactAddress = address
            self.viewController?.contactAddressTextField.text = address
        }
        
        if let note = contact.note {
            self.viewController?.contactNote = note
            self.viewController?.contactNoteTextField.text = note
        }
        
        //just for debug:
        
        //interactor?.updateEncryptedContact(contactID: contact.contactID!.description, name:  contact.contactName ?? "name", email:  contact.email ?? "emal", phone: contact.phone ?? "", address: contact.address ?? "", note: contact.note ?? "")
    }
    
    func setupSaveButton(contactName: String, contactEmail: String) {
        
        var saveButtonEnable : Bool = false
        
        if (formatterService?.validateNameLench(enteredName: contactName))! {
            if (formatterService?.validateEmailFormat(enteredEmail: contactEmail))! {
                saveButtonEnable = true
            } else {
                saveButtonEnable = false
            }
        } else {
            saveButtonEnable = false
        }
        
        self.viewController?.navigationItem.rightBarButtonItem?.isEnabled = saveButtonEnable
    }
    
    func saveButtonPressed() {
        
        if (self.viewController?.editMode)! {
            if let contactID = self.viewController!.contact!.contactID {                
                if self.viewController!.contactsEncrypted {
                    self.interactor?.updateEncryptedContact(contactID: contactID.description, name: (self.viewController?.contactName)!, email: (self.viewController?.contactEmail)!, phone: (self.viewController?.contactPhone)!, address: (self.viewController?.contactAddress)!, note: (self.viewController?.contactNote)!)
                } else {
                    self.interactor?.updateContact(contactID: contactID.description, name: (self.viewController?.contactName)!, email: (self.viewController?.contactEmail)!, phone: (self.viewController?.contactPhone)!, address: (self.viewController?.contactAddress)!, note: (self.viewController?.contactNote)!)
                }
            }
        } else {
            self.interactor?.createContact(name: (self.viewController?.contactName)!, email: (self.viewController?.contactEmail)!, phone: (self.viewController?.contactPhone)!, address: (self.viewController?.contactAddress)!, note: (self.viewController?.contactNote)!)
        }
    }
}

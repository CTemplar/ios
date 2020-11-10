//
//  AddContactInteractor.swift
//  CTemplar
//
//  Created by Tatarinov Dmitry on 20.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import Networking

class AddContactInteractor {
    
    var viewController  : AddContactViewController?
    var presenter       : AddContactPresenter?
    var apiService      : APIService?

    func createContact(name: String, email: String, phone: String, address: String, note: String, encrypted: Bool) {
        
        if encrypted {
            Loader.start()
            
            apiService?.createEncryptedContact(name: name, email: email, phone: phone, address: address, note: note) {(result) in
                
                switch(result) {
                    
                case .success(let value):
                    print("createEncryptedContact:", value)
                    self.viewController?.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    print("error:", error)
                    self.viewController?.showAlert(with: "Contacts Error",
                                                   message: error.localizedDescription,
                                                   buttonTitle: Strings.Button.closeButton.localized)
                }
                
                Loader.stop()
            }
        } else {
            Loader.start()
            
            apiService?.createContact(name: name, email: email, phone: phone, address: address, note: note) {(result) in
                
                switch(result) {
                    
                case .success(let value):
                    print("createContact:", value)
                    self.viewController?.navigationController?.popViewController(animated: true)
                    
                    //need send to update Contact list
                    
                case .failure(let error):
                    print("error:", error)
                    self.viewController?.showAlert(with: "Contacts Error",
                                                   message: error.localizedDescription,
                                                   buttonTitle: Strings.Button.closeButton.localized)
                }
                
                Loader.stop()
            }
        }
    }
    
    func updateContact(contactID: String, name: String, email: String, phone: String, address: String, note: String, encrypted: Bool) {
        
        if encrypted {
            Loader.start()
            
            apiService?.updateEncryptedContact(contactID: contactID, name: name, email: email, phone: phone, address: address, note: note) {(result) in
                
                switch(result) {
                    
                case .success(let value):
                    print("updateContact:", value)
                    self.viewController?.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    print("error:", error)
                    self.viewController?.showAlert(with: "Contacts Error",
                                                   message: error.localizedDescription,
                                                   buttonTitle: Strings.Button.closeButton.localized)
                }
                
                Loader.stop()
            }
        } else {
            Loader.start()
            
            apiService?.updateContact(contactID: contactID, name: name, email: email, phone: phone, address: address, note: note) {(result) in
                switch(result) {
                case .success(let value):
                    print("updateContact:", value)
                    self.viewController?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("error:", error)
                    self.viewController?.showAlert(with: "Contacts Error",
                                                   message: error.localizedDescription,
                                                   buttonTitle: Strings.Button.closeButton.localized)
                }
                
                Loader.stop()
            }
        }
    }   
}

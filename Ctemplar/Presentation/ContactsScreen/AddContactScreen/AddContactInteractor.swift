//
//  AddContactInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class AddContactInteractor {
    
    var viewController  : AddContactViewController?
    var presenter       : AddContactPresenter?
    var apiService      : APIService?

    func createContact(name: String, email: String, phone: String, address: String, note: String) {
        
        HUD.show(.progress)
        
        apiService?.createContacts(name: name, email: email, phone: phone, address: address, note: note) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("createContact:", value)
                self.viewController?.navigationController?.popViewController(animated: true)
                
                //need send to update Contact list
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Contacts Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
}

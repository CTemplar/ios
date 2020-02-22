//
//  AddFolderInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 19.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class AddFolderInteractor {
    
    var viewController  : AddFolderViewController?
    var apiService      : APIService?
    var formatterService        : FormatterService?
    
    func validateFolderName(text: String?) {
        guard let text = text else {
            self.viewController?.darkLineView.backgroundColor = k_redColor
            self.setAddButton(enable: false)
            return
        }
        let nameValid = self.formatterService?.validateFolderNameFormat(enteredName: text) ?? false
        
        self.viewController?.darkLineView.backgroundColor = nameValid ? k_sideMenuColor : k_redColor
        self.setAddButton(enable: nameValid && (self.viewController?.selectedHexColor.count ?? 0) > 0)
    }
    
    func validFolderName(text: String?) -> Bool {
        return formatterService?.validateFolderNameFormat(enteredName: text ?? "") ?? false
    }
    
    func setAddButton(enable: Bool) {
        
        if enable {
            self.viewController?.addButton.isEnabled = true
            self.viewController?.addButton.alpha = 1.0
        } else {
            self.viewController?.addButton.isEnabled = false
            self.viewController?.addButton.alpha = 0.6
        }
    }
    
    func createCustomFolder(name: String, colorHex: String) {
         
        apiService?.createCustomFolder(name: name, color: colorHex) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("value:", value)
                self.viewController?.delegate?.didAddFolder(value as! Folder)
                self.viewController?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Create Folder Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }

}

//
//  EditFolderInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class EditFolderInteractor {
    
    var viewController  : EditFolderViewController?
    var apiService      : APIService?
    var formatterService        : FormatterService?
    
    func validateFolderName(text: String) {
        
        var nameValid : Bool = false
        
        if (self.formatterService?.validateNameFormat(enteredName: text))! {
            self.viewController?.folderName = text
            self.viewController?.darkLineView.backgroundColor = k_sideMenuColor
            nameValid = true
        } else {
            self.viewController?.darkLineView.backgroundColor = k_redColor           
            nameValid = false
        }
        
        if (self.viewController?.selectedHexColor.count)! > 0 && nameValid {
            self.setSaveButton(enable: true)
        } else {
            self.setSaveButton(enable: false)
        }
    }
    
    func setSaveButton(enable: Bool) {
        
        if enable {
            self.viewController?.saveBarButtonItem.isEnabled = true
            //self.viewController?.saveBarButtonItem.alpha = 1.0
        } else {
            self.viewController?.saveBarButtonItem.isEnabled = false
            //self.viewController?.saveBarButtonItem.alpha = 0.6
        }
    }
    
    func updateCustomFolder(name: String, colorHex: String) {
        
        apiService?.updateCustomFolder(folderID: (self.viewController!.folder!.folderID?.description)!, name: name, color: colorHex) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("value:", value)
                self.viewController?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Create Folder Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}

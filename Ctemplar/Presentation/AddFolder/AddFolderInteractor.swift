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
    
    func validateFolderName(text: String) {
        
        var nameValid : Bool = false
        
        if (self.formatterService?.validateNameFormat(enteredName: text))! {
            self.viewController?.folderName = text
            self.viewController?.darkLineView.backgroundColor = k_sideMenuColor
            nameValid = true
        } else {
            self.viewController?.darkLineView.backgroundColor = k_redColor
            self.setAddButton(enable: true)
            nameValid = false
        }
        
        if (self.viewController?.selectedHexColor.count)! > 0 && nameValid {
            self.setAddButton(enable: true)
        } else {
            self.setAddButton(enable: false)
        }
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
}

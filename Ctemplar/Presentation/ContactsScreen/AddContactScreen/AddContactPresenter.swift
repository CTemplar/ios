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
    }
}

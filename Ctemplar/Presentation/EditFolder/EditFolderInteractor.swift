//
//  EditFolderInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import Networking

class EditFolderInteractor {
    
    var viewController  : EditFolderViewController?
    var apiService      : APIService?
    var formatterService        : FormatterService?
    
    func setFolderProperties(folder: Folder) {
        
        if let name = folder.folderName {
            self.viewController!.folderName = name
            self.viewController?.folderNameTextField.text = name
        }
        
        if let color = folder.color {
            self.viewController!.selectedHexColor = color
            let index = self.viewController!.colorPicker.findColorIndexTag(colorHex: color)
            if index > -1 {
                let tag = index + k_colorButtonsTag + 1
                self.viewController!.colorPicker.selectedButtonTag = tag
                self.viewController!.colorPicker.setButtonSelected(tag: tag)
            }
        }
        
        self.viewController?.navigationItem.title = self.viewController!.folderName
    }
    
    func validateFolderName(text: String) {
        
        var nameValid : Bool = false
        
        if (self.formatterService?.validateFolderNameFormat(enteredName: text))! {
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
    
    func updateCustomFolder(folderID: Int, name: String, colorHex: String) {
        apiService?.updateCustomFolder(folderID: folderID.description, name: name, color: colorHex) {(result) in
            switch(result) {
            case .success(let value):
                print("value:", value)
                self.viewController!.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print("error:", error)
                self.viewController?.showAlert(with: "Update Folder Error",
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
            }
        }
    }
    
    func deleteFolder(folderID: Int) {
        
        apiService?.deleteCustomFolder(folderID: folderID.description) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("value:", value)
                self.viewController!.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                print("error:", error)
                self.viewController?.showAlert(with: "Delete Folder Error",
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
            }
        }
    }
    
    func showDeleteFolderAlert(folderID: Int) {
        let params = AlertKitParams(
            title: "deleteFolderTitle".localized(),
            message: "deleteFolder".localized(),
            cancelButton: "cancelButton".localized(),
            otherButtons: ["deleteButton".localized()]
        )
        
        viewController?.showAlert(with: params, onCompletion: { [weak self] (index) in
            switch index {
            case 0:
                DPrint("Cancel Delete")
            default:
                DPrint("Delete")
                self?.deleteFolder(folderID: folderID)
            }
        })
    }
}

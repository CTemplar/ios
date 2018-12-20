//
//  EditFolderViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class EditFolderViewController: UIViewController {
    
    var interactor       : EditFolderInteractor?
    
    var folder : Folder!
    
    @IBOutlet var deleteButton              : UIButton!
    
    @IBOutlet var saveBarButtonItem         : UIBarButtonItem!
    
    @IBOutlet var folderNameTextField       : UITextField!
    @IBOutlet var darkLineView              : UIView!
    @IBOutlet var colorPickerSuperView      : UIView!
    
    var selectedHexColor : String = ""
    var folderName : String = ""
    
    var colorPicker : ColorPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = EditFolderConfigurator()
        configurator.configure(viewController: self)
        
        self.colorPicker = ColorPickerView()
        self.colorPicker.delegate = self
        self.colorPickerSuperView.add(subview: colorPicker)
        
        if self.folder != nil {
            self.interactor?.setFolderProperties(folder: self.folder!)
        }
        
        self.interactor?.validateFolderName(text: self.folderName)        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.colorPicker.setupColorPicker(width: self.colorPickerSuperView.bounds.width, height: self.colorPickerSuperView.bounds.height)        
    }
    
    //MARK: - IBActions
    
    @IBAction func deleteButtonPressed(_ sender: AnyObject) {
        
       
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textTyped(_ sender: UITextField) {
        
        self.interactor?.validateFolderName(text: sender.text!)
    }
}

extension EditFolderViewController: ColorPickerViewDelegate {
    
    func selectColorAction(colorHex: String) {
        print("selected colorHex:", colorHex)
        self.selectedHexColor = colorHex
        self.interactor?.validateFolderName(text: self.folderName)
    }
}

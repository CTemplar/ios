//
//  EditFolderViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Networking

class EditFolderViewController: UIViewController {
    
    var interactor       : EditFolderInteractor?
    
    var folder : Folder!
    
    @IBOutlet var deleteButton              : UIButton!
    
    @IBOutlet var saveBarButtonItem         : UIBarButtonItem!
    
    @IBOutlet var folderNameTextField       : UITextField!
    @IBOutlet var darkLineView              : UIView!
    @IBOutlet var colorPickerSuperView      : UIView!
    
    @IBOutlet var colorPickerSuperViewHeightConstraint          : NSLayoutConstraint!
    
    var selectedHexColor : String = ""
    var folderName : String = ""
    
    var colorPicker : ColorPickerView!
    
    let k_colorPickerOffset : CGFloat = 32.0
    var k_colorPickeriPadHeight : CGFloat = 180.0
    
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
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.colorPicker.setupColorPicker(width: self.colorPickerSuperView.bounds.width)
        colorPickerSuperViewHeightConstraint.constant = colorPicker.frame.height
        view.layoutIfNeeded()
        if (Device.IS_IPAD) {
            //k_colorPickeriPadHeight = self.colorPicker.calculateColorPickerHeight(width: self.colorPickerSuperView.bounds.width)
           // self.colorPickerSuperViewHeightConstraint.constant = k_colorPickeriPadHeight
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func deleteButtonPressed(_ sender: AnyObject) {
        
        if let folderID = self.folder.folderID {
            self.interactor?.showDeleteFolderAlert(folderID: folderID)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        
        if let folderID = self.folder.folderID {
            self.interactor?.updateCustomFolder(folderID: folderID, name: self.folderName, colorHex: self.selectedHexColor)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textTyped(_ sender: UITextField) {
        
        self.interactor?.validateFolderName(text: sender.text!)
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        self.folderNameTextField.resignFirstResponder()
    }
    
    //MARK: - Orientation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
 /*
        var width : CGFloat = 0.0
        
        if (Device.IS_IPAD) {
            if UIDevice.current.orientation.isLandscape {
                width = (self.splitViewController?.secondaryViewController?.view.bounds.height)! * (1.0 - (self.splitViewController?.preferredPrimaryColumnWidthFraction)!) - k_colorPickerOffset/8.0
            } else {
                width = (self.splitViewController?.secondaryViewController?.view.bounds.height)! - k_colorPickerOffset
            }
            
            self.colorPicker.updateColorPickerFrame(width: width, height: k_colorPickeriPadHeight)
            k_colorPickeriPadHeight = self.colorPicker.calculateColorPickerHeight(width: self.colorPickerSuperView.bounds.width)
            self.view.layoutIfNeeded()
        }*/
    }
}

extension EditFolderViewController: ColorPickerViewDelegate {
    
    func selectColorAction(colorHex: String) {
        print("selected colorHex:", colorHex)
        self.selectedHexColor = colorHex
        self.interactor?.validateFolderName(text: self.folderName)
    }
}

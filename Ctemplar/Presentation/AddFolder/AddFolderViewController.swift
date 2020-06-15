//
//  AddFolderViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 19.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit

class AddFolderViewController: UIViewController {
    
    var interactor       : AddFolderInteractor?
    
    @IBOutlet var addButton                 : UIButton!
    
    @IBOutlet var folderNameTextField       : UITextField!    
    @IBOutlet var darkLineView              : UIView!
    @IBOutlet var colorPickerSuperView      : UIView!
    
    @IBOutlet var colorPickerSuperViewHeightConstraint          : NSLayoutConstraint!
    
    var delegate: AddFolderDelegate?
    
    var selectedHexColor : String = ""
    var folderName: String?
    
    let k_colorPickerOffset : CGFloat = 32.0
    var k_colorPickeriPadHeight : CGFloat = 90.0
    
    var colorPicker : ColorPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = AddFolderConfigurator()
        configurator.configure(viewController: self)
        
        self.colorPicker = ColorPickerView()
        self.colorPicker.delegate = self
        self.colorPickerSuperView.add(subview: colorPicker)
        
        self.interactor?.validateFolderName(text: self.folderName ?? "")
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.colorPicker.selectedButtonTag = k_colorButtonsTag + 4
        if (Device.IS_IPAD) {
            //k_colorPickeriPadHeight = self.colorPicker.calculateColorPickerHeight(width: self.colorPickerSuperView.bounds.width)
            //self.colorPickerSuperViewHeightConstraint.constant = k_colorPickeriPadHeight
        }
        self.colorPicker.setupColorPicker(width: self.colorPickerSuperView.bounds.width)
        colorPickerSuperViewHeightConstraint.constant = colorPicker.frame.height
        view.layoutIfNeeded()
        
        self.folderNameTextField.becomeFirstResponder()
    }
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        if let name = folderName,
            interactor?.validFolderName(text: folderName) == true {
            self.interactor?.createCustomFolder(name: name, colorHex: self.selectedHexColor)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textTyped(_ sender: UITextField) {
        folderName = sender.text
        self.interactor?.validateFolderName(text: sender.text!)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Orientation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if (Device.IS_IPAD) {

            _ = self.view.bounds.height - k_colorPickerOffset
            
            //self.colorPicker.updateColorPickerFrame(width: width, height: k_colorPickeriPadHeight)
            //k_colorPickeriPadHeight = self.colorPicker.calculateColorPickerHeight(width: self.colorPickerSuperView.bounds.width)
            self.view.layoutIfNeeded()
        }
    }
}

extension AddFolderViewController: ColorPickerViewDelegate {
    
    func selectColorAction(colorHex: String) {
        print("selected colorHex:", colorHex)
        self.selectedHexColor = colorHex
        self.interactor?.validateFolderName(text: self.folderName)
    }
}

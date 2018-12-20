//
//  AddFolderViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 19.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class AddFolderViewController: UIViewController {
    
    var interactor       : AddFolderInteractor?
    
    @IBOutlet var addButton                 : UIButton!
    
    @IBOutlet var folderNameTextField       : UITextField!    
    @IBOutlet var darkLineView              : UIView!
    @IBOutlet var colorPickerSuperView      : UIView!
    
    @IBOutlet var buttonBottomOffsetConstraint          : NSLayoutConstraint!
    
    var selectedHexColor : String = ""
    var folderName : String = ""
    
    var colorPicker : ColorPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = AddFolderConfigurator()
        configurator.configure(viewController: self)
        
        self.colorPicker = ColorPickerView()
        self.colorPicker.delegate = self
        self.colorPickerSuperView.add(subview: colorPicker)
        
        self.interactor?.validateFolderName(text: self.folderName)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.colorPicker.selectedButtonTag = k_colorButtonsTag + 4
        self.colorPicker.setupColorPicker(width: self.colorPickerSuperView.bounds.width, height: self.colorPickerSuperView.bounds.height)
        
        self.interactor?.setupBottomButtons()
        
        self.folderNameTextField.becomeFirstResponder()
    }
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        
        self.interactor?.createCustomFolder(name: self.folderName, colorHex: self.selectedHexColor)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textTyped(_ sender: UITextField) {
        
        self.interactor?.validateFolderName(text: sender.text!)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            
            self.dismiss(animated: true, completion: nil)
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

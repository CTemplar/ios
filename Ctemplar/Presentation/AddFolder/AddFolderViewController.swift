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
    
    @IBOutlet var addButton                 : UIButton!
    
    @IBOutlet var folderNameTextField       : UITextField!    
    @IBOutlet var darkLineView              : UIView!
    @IBOutlet var colorPickerSuperView           : UIView!
    
    var colorPicker : ColorPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.colorPicker = ColorPickerView()
        self.colorPickerSuperView.add(subview: colorPicker)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.colorPicker.selectedButtonTag = k_colorButtonsTag + 4
        self.colorPicker.setupColorPicker(width: self.colorPickerSuperView.bounds.width, height: self.colorPickerSuperView.bounds.height)
    }
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textTyped(_ sender: UITextField) {
        
       // self.setInputText(textField: sender)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

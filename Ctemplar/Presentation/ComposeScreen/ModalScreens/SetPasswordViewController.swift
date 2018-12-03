//
//  SetPasswordViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class SetPasswordViewController: UIViewController {

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
    }
    
    //MARK: - IBActions
    
    @IBAction func applyButtonPressed(_ sender: AnyObject) {
        
       
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

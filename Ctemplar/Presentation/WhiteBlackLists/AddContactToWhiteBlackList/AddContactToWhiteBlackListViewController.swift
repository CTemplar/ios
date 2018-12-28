//
//  AddContactToWhiteBlackListViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 28.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

protocol AddContactToWhiteBlackListDelegate {
    func applyAction()
    func cancelAction()
}

class AddContactToWhiteBlackListViewController: UIViewController {

    @IBOutlet var applyButton           : UIButton!
    
    var delegate    : AddContactToWhiteBlackListDelegate?
    var mode: WhiteBlackListsMode!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
    }
    
    //MARK: - IBActions
    
    @IBAction func applyButtonPressed(_ sender: AnyObject) {
        
        self.delegate?.applyAction()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.delegate?.cancelAction()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            self.delegate?.cancelAction()
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//
//  SchedulerViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 13.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

protocol SchedulerDelegate {
    func applyAction(date: Date)
    func cancelAction()
}

class SchedulerViewController: UIViewController {
    
    var delegate    : SchedulerDelegate?
    
    @IBOutlet var scheduleButton        : UIButton!
    @IBOutlet var titleLabel            : UILabel!
    @IBOutlet var textLabel             : UILabel!
    @IBOutlet var dateLabel             : UILabel!
    @IBOutlet var datePicker            : UIDatePicker!
    @IBOutlet var mainView              : UIView!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            
    }
    
    //MARK: - IBActions
    
    @IBAction func scheduleButtonPressed(_ sender: AnyObject) {
        
      
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

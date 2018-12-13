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
    func cancelSchedulerAction()
}

class SchedulerViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var formatterService : FormatterService?
    
    var delegate    : SchedulerDelegate?
    
    @IBOutlet var scheduleButton        : UIButton!
    @IBOutlet var titleLabel            : UILabel!
    @IBOutlet var textLabel             : UILabel!
    @IBOutlet var dateLabel             : UILabel!
    @IBOutlet var datePicker            : UIDatePicker!
    @IBOutlet var mainView              : UIView!
    
    var mode: SchedulerMode!
    var scheduledDate = Date()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.formatterService = appDelegate.applicationManager.formatterService
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupScreen()
    }
    
    func setupScreen() {
        
        switch self.mode! {
        case SchedulerMode.selfDestructTimer:
            self.titleLabel.text = "selfDestructTimer".localized()
            self.textLabel.text = "selfDestructTimerText".localized()
            break
        case SchedulerMode.deadManTimer:
            self.titleLabel.text = "deadManTimer".localized()
            self.textLabel.text = "deadManTimerText".localized()
            break
        case SchedulerMode.delayedDelivery:
            self.titleLabel.text = "delayedDelivery".localized()
            self.textLabel.text = "delayedDeliveryText".localized()
            break 
        }
        
        self.setDateLabel()
    }
    
    func setDateLabel() {
        
        switch self.mode! {
        case SchedulerMode.selfDestructTimer:
            self.dateLabel.text = self.scheduledDate.scheduleTimeCountForDestruct()
            break
        case SchedulerMode.deadManTimer:
            self.dateLabel.text = self.formatterService?.formatDateToDelayedDeliveryDateString(date: self.scheduledDate)
            break
        case SchedulerMode.delayedDelivery:
            self.dateLabel.text = self.formatterService?.formatDateToDelayedDeliveryDateString(date: self.scheduledDate)
            break
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func scheduleButtonPressed(_ sender: AnyObject) {
        
        self.delegate?.applyAction(date: self.scheduledDate)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.delegate?.cancelSchedulerAction()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            self.delegate?.cancelSchedulerAction()
            self.dismiss(animated: true, completion: nil)
        }
    }
}

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
    func applyAction(date: Date, mode: SchedulerMode)
    func cancelSchedulerAction()
}

class SchedulerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var formatterService : FormatterService?
    
    var delegate    : SchedulerDelegate?
    
    @IBOutlet var scheduleButton        : UIButton!
    @IBOutlet var titleLabel            : UILabel!
    @IBOutlet var textLabel             : UILabel!
    @IBOutlet var dateLabel             : UILabel!
    @IBOutlet var datePicker            : UIDatePicker!
    @IBOutlet var customDatePicker      : UIPickerView!
    @IBOutlet var mainView              : UIView!
    
    var mode: SchedulerMode!
    var scheduledDate = Date()
    var pickerData: [[String]] = [[String]]()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formatterService = appDelegate.applicationManager.formatterService
        
        //pickerData = [["1", "2", "3", "4"],["a", "b", "c", "d"]]
        self.setupCustomPickerData()
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupScreen()
        self.setupPicker()
    }
    
    func setupCustomPickerData() {
        
        var daysList = [String]()
        var hoursist = [String]()
        
        var daySuffix = ""
        var hourSuffix = ""
        
        for day in 0...99 {
            
            if day == 1 {
                daySuffix = "day"
            } else {
                daySuffix = "days"
            }
            
            let dayString = String(format: "%i ", day) + daySuffix
            daysList.append(dayString)
        }
        
        for hour in 0...24 {
            
            if hour == 1 {
                hourSuffix = "hour"
            } else {
                hourSuffix = "hours"
            }
            
            let hourString = String(format: "%i ", hour) + hourSuffix
            hoursist.append(hourString)
        }
        
        self.pickerData.append(daysList)
        self.pickerData.append(hoursist)
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
            self.dateLabel.text = self.scheduledDate.scheduleTimeCountForDestruct()
            break
        case SchedulerMode.delayedDelivery:
            self.dateLabel.text = self.formatterService?.formatDateToDelayedDeliveryDateString(date: self.scheduledDate)
            break
        }
    }
    
    func setupPicker() {
        
        switch self.mode! {
        case SchedulerMode.selfDestructTimer:
            //self.datePicker.datePickerMode = .date
            self.datePicker.isHidden = true
            self.customDatePicker.isHidden = false
            break
        case SchedulerMode.deadManTimer:
            //self.datePicker.datePickerMode = .dateAndTime
            self.datePicker.isHidden = true
            self.customDatePicker.isHidden = false
            break
        case SchedulerMode.delayedDelivery:
            self.datePicker.datePickerMode = .dateAndTime
            self.datePicker.isHidden = false
            self.customDatePicker.isHidden = true
            break
        }
        
        self.datePicker.date = self.scheduledDate
    }
    
    //MARK: - IBActions
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        
        self.scheduledDate = sender.date
        self.setDateLabel()
        
        self.scheduledDate.hoursCountFromNow() //debug
    }
    
    @IBAction func scheduleButtonPressed(_ sender: AnyObject) {
        
        self.delegate?.applyAction(date: self.scheduledDate, mode: self.mode)
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
    
    //MARK: - Custom Date Picker Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}

//
//  SchedulerViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 13.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
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
    
    var days = 0
    var hours = 0
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formatterService = appDelegate.applicationManager.formatterService
        
        self.setupCustomPickerData()
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupScreen()
        self.setupPicker()
        self.validateScheduledDate()
    }
    
    func setupCustomPickerData() {
        
        var daysList = [String]()
        var hoursist = [String]()
        
        var daySuffix = ""
        var hourSuffix = ""
        
        for day in 0...99 {
            
            var daysLastDigit = 0
            
            if day < 10 || day > 19 {
                let daysString = day.description
                daysLastDigit = Int(String(daysString.last!))!
            } else {
                daysLastDigit = day
            }

            if daysLastDigit == 1 {
                daySuffix = "oneDay".localized()
            } else {
                daySuffix = "manyDays".localized()
                if daysLastDigit < 5 {
                    daySuffix = "manyDaysx".localized()
                }
            }
            
            if daysLastDigit == 0 {
                daySuffix = "manyDays".localized()
            }
            
            let dayString = String(format: "%i ", day) + daySuffix.dropLast()
            daysList.append(dayString)
        }
        
        for hour in 0...24 {
            
            var hoursLastDigit = 0
            
            if hour < 10 || hour > 19 {
                let hoursString = hour.description
                hoursLastDigit = Int(String(hoursString.last!))!
            } else {
                hoursLastDigit = hour
            }
            
            if hoursLastDigit == 1 {
                hourSuffix = "oneHour".localized()
            } else {
                hourSuffix = "manyHours".localized()
                if hoursLastDigit < 5 {
                    hourSuffix = "manyHoursx".localized()
                }
            }
            
            if hoursLastDigit == 0 {
                hourSuffix = "manyHours".localized()
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
            self.dateLabel.text = self.scheduledDate.formatScheduleDestructionTimeToString(days: self.days, hours: self.hours, minutes: 0)
            break
        case SchedulerMode.deadManTimer:
            self.dateLabel.text = self.scheduledDate.formatScheduleDestructionTimeToString(days: self.days, hours: self.hours, minutes: 0)
            break
        case SchedulerMode.delayedDelivery:
            self.dateLabel.text = self.formatterService?.formatDateToDelayedDeliveryDateString(date: self.scheduledDate)
            break
        }
    }
    
    func setupPicker() {
        
        switch self.mode! {
        case SchedulerMode.selfDestructTimer:
            self.datePicker.isHidden = true
            self.customDatePicker.isHidden = false
            break
        case SchedulerMode.deadManTimer:
            self.datePicker.isHidden = true
            self.customDatePicker.isHidden = false
            break
        case SchedulerMode.delayedDelivery:
            self.datePicker.datePickerMode = .dateAndTime
            self.datePicker.isHidden = false
            self.customDatePicker.isHidden = true
            break
        }
        
        let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
        self.datePicker.locale = Locale.init(identifier: appLang)
        self.datePicker.date = self.scheduledDate
        self.setCustomPickerScheduledDate()
    }
    
    //MARK: - IBActions
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        
        self.scheduledDate = sender.date
        self.setDateLabel()
        self.validateScheduledDate()
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
        
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0:
             let pickedDaysString = pickerData[component][row]
             let pickedDays = pickedDaysString.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
             if pickedDays.count > 0 {
                self.days = Int(pickedDays.first!)!
             }
        case 1:
            let pickedHoursString = pickerData[component][row]
            let pickedHours = pickedHoursString.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
            if pickedHours.count > 0 {
                self.hours = Int(pickedHours.first!)!
            }
        default:
            break
        }
        
        //print("days:", days, "hours:", hours)
        
        self.scheduledDate = self.formatScheduledDateWith(days: self.days, hours: self.hours)
        self.setDateLabel()
        self.validateScheduledDate()
    }
    
    func formatScheduledDateWith(days: Int, hours: Int) -> Date {
        
        let hoursTotal = (self.days * 24) + self.hours
        
        let date = self.formatterService?.formatDeadManDurationToDate(duration: hoursTotal)
        
        return date!
    }
    
    func setCustomPickerScheduledDate() {
        
        if let minutes = self.formatterService?.calculateMinutesCountFor(date: self.scheduledDate) {
            let hours = lroundf(Float(minutes)/60.0)
            
            var currentDay = 0
            var currentHour = 0
            
            if hours > 24 {
                currentDay = hours / 24
                currentHour = hours - currentDay * 24
            } else {
                currentHour = hours
            }
            
            print("currentDay:", currentDay)
            print("currentHour:", currentHour)
            
            self.customDatePicker.selectRow(currentDay, inComponent: 0, animated: false)
            self.customDatePicker.selectRow(currentHour, inComponent: 1, animated: false)
        }
    }
    
    func validateScheduledDate() {
                
        if let minutes = self.formatterService?.calculateMinutesCountFor(date: self.scheduledDate) {
            print("minutes from now:", minutes)
        
            if minutes > 0 {
                scheduleButton.isEnabled = true
                scheduleButton.alpha = 1.0
            } else {
                scheduleButton.isEnabled = false
                scheduleButton.alpha = 0.6
            }
        }
    }
}

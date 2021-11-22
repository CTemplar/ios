import Foundation
import UIKit
import Utility

class SchedulerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: IBOutlets
    @IBOutlet weak var scheduleButton: UIBarButtonItem!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var customDatePicker: UIPickerView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    // MARK: Properties
    private let formatterService = UtilityManager.shared.formatterService
    
    var onCompletion: ((SchedulerMode, Date) -> Void)?
   
    var mode: SchedulerMode!
    
    var scheduledDate = Date()
    
    private var pickerData: [[String]] = []
    
    private var days = 0
    
    private var hours = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    private func setupCustomPickerData() {
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
                daySuffix = Strings.Formatter.oneDay.localized
            } else {
                daySuffix = Strings.Formatter.manyDays.localized
                if daysLastDigit < 5 {
                    daySuffix = Strings.Formatter.manyDaysx.localized
                }
            }
            
            if daysLastDigit == 0 {
                daySuffix = Strings.Formatter.manyDays.localized
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
                hourSuffix = Strings.Formatter.oneHour.localized
            } else {
                hourSuffix = Strings.Formatter.manyHours.localized
                if hoursLastDigit < 5 {
                    hourSuffix = Strings.Formatter.manyHoursx.localized
                }
            }
            
            if hoursLastDigit == 0 {
                hourSuffix = Strings.Formatter.manyHours.localized
            }
            
            let hourString = String(format: "%i ", hour) + hourSuffix
            hoursist.append(hourString)
        }
        
        self.pickerData.append(daysList)
        self.pickerData.append(hoursist)
    }
    
    private func setupScreen() {
        switch mode {
        case .selfDestructTimer:
            navigationBar.topItem?.title = Strings.Scheduler.selfDestructTimer.localized
            textLabel.text = Strings.Scheduler.selfDestructTimerText.localized + "\n" + Strings.Scheduler.selfDestructMessageText.localized
        case .deadManTimer:
            navigationBar.topItem?.title = Strings.Scheduler.deadManTimer.localized
            textLabel.text = Strings.Scheduler.deadManTimerText.localized
        case .delayedDelivery:
            navigationBar.topItem?.title = Strings.Scheduler.delayedDelivery.localized
            textLabel.text = Strings.Scheduler.delayedDeliveryText.localized
        case .none: break
        }
        setDateLabel()
    }
    
    private func setDateLabel() {
        switch mode {
        case .selfDestructTimer:
            dateLabel.text = scheduledDate.formatScheduleDestructionTimeToString(days: days, hours: hours, minutes: 0)
        case .deadManTimer:
            dateLabel.text = scheduledDate.formatScheduleDestructionTimeToString(days: days, hours: hours, minutes: 0)
        case .delayedDelivery:
            dateLabel.text = formatterService.formatDateToDelayedDeliveryDateString(date: scheduledDate)
        case .none: break
        }
    }
    
    func setupPicker() {
        switch mode {
        case .selfDestructTimer:
            datePicker.isHidden = true
            customDatePicker.isHidden = false
        case .deadManTimer:
            datePicker.isHidden = true
            customDatePicker.isHidden = false
        case .delayedDelivery:
            datePicker.datePickerMode = .dateAndTime
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
            } else {
                // Fallback on earlier versions
            }
            datePicker.isHidden = false
            customDatePicker.isHidden = true
        case .none: break
        }
        let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
        self.datePicker.locale = Locale.init(identifier: appLang)
        self.datePicker.date = self.scheduledDate
        self.setCustomPickerScheduledDate()
    }
    
    // MARK: - Actions
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        scheduledDate = sender.date
        setDateLabel()
        validateScheduledDate()
    }
    
    @IBAction func scheduleButtonPressed(_ sender: AnyObject) {
        onCompletion?(mode, scheduledDate)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Custom Date Picker Delegate
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
        scheduledDate = self.formatScheduledDateWith(days: self.days, hours: self.hours)
        setDateLabel()
        validateScheduledDate()
    }
    
    // MARK: - Helpers
    private func formatScheduledDateWith(days: Int, hours: Int) -> Date {
        let hoursTotal = (self.days * 24) + self.hours
        let date = formatterService.formatDeadManDurationToDate(duration: hoursTotal)
        return date ?? Date()
    }
    
    private func setCustomPickerScheduledDate() {
        if let minutes = formatterService.calculateMinutesCountFor(date: self.scheduledDate) {
            let hours = lroundf(Float(minutes)/60.0)
            
            var currentDay = 0
            var currentHour = 0
            
            if hours > 24 {
                currentDay = hours / 24
                currentHour = hours - currentDay * 24
            } else {
                currentHour = hours
            }
            
            self.customDatePicker.selectRow(currentDay, inComponent: 0, animated: false)
            self.customDatePicker.selectRow(currentHour, inComponent: 1, animated: false)
        }
    }
    
    private func validateScheduledDate() {
        if let minutes = formatterService.calculateMinutesCountFor(date: self.scheduledDate) {
            scheduleButton.isEnabled = minutes > 0
        }
    }
}

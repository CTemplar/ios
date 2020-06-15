import Foundation
import UIKit

public extension Date {
    func timeCountForDelivery(short: Bool) -> NSMutableAttributedString {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let remainDays = secondsAgo / day
        let remainHoursInDay = (secondsAgo - remainDays * day) / hour
        let remainMinutesInHour = (secondsAgo - remainDays * day - remainHoursInDay * hour) / minute
        let timeString = formatDelayDeliveryTimeToString(days: abs(remainDays), hours: abs(remainHoursInDay), minutes: abs(remainMinutesInHour), short: short)
        
        return timeString
    }
    
    func timeCountForDestruct(short: Bool) -> NSMutableAttributedString {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let remainDays = secondsAgo / day
        let remainHoursInDay = (secondsAgo - remainDays * day) / hour
        let remainMinutesInHour = (secondsAgo - remainDays * day - remainHoursInDay * hour) / minute
        let timeString = formatDestructionTimeToString(days: abs(remainDays), hours: abs(remainHoursInDay), minutes: abs(remainMinutesInHour), short: short)
        return timeString
    }
    
    func formatDestructionTimeToString(days: Int, hours: Int, minutes: Int, short: Bool) -> NSMutableAttributedString {
        var destructionLabelAttributedText = ""
        var dateString = ""
        var location = 0
        var length = 5
       
        if !short {
            location = Strings.Formatter.deleteIn.localized.count
            destructionLabelAttributedText = "\(destructionLabelAttributedText)\(Strings.Formatter.deleteIn.localized)"
        }
            
        if days > 0 {
            length = 8
            if days > 10 {
                length = 9
            }
            dateString = dateString + String(format: "%d", days) + Strings.Formatter.daySuffix.localized
        }
        
        dateString = "\(dateString)\(String(format: "%02d:%02d", hours, minutes))"
        
        destructionLabelAttributedText = destructionLabelAttributedText + dateString
        
        let attributedString = NSMutableAttributedString(string: destructionLabelAttributedText, attributes: [
            .font: AppStyle.CustomFontStyle.Regular.font(withSize: 9.0)!,
            .foregroundColor: UIColor.white,
            .kern: 0.0
            ])
        
        attributedString.addAttribute(.font, value: AppStyle.CustomFontStyle.Bold.font(withSize: 9.0)!,
                                      range: NSRange(location: location, length: length))
        
        return attributedString
    }
    
    func formatDelayDeliveryTimeToString(days: Int, hours: Int, minutes: Int, short: Bool) -> NSMutableAttributedString {
        var destructionLabelAttributedText = ""
        var dateString : String = ""
        var location = 0
        var length = 5
        
        if !short {
            location = Strings.Formatter.delayTime.localized.count//11
            destructionLabelAttributedText = "\(destructionLabelAttributedText)\(Strings.Formatter.delayTime.localized)"
        }
        
        if days > 0 {
            length = 8
            if days > 10 {
                length = 9
            }
            dateString = dateString + String(format: "%d", days) + "daySuffix".localized()//%02d
        }
        
        dateString = "\(dateString)\(String(format: "%02d:%02d", hours, minutes))"
        
        destructionLabelAttributedText = "\(destructionLabelAttributedText)\(dateString)"
        
        let attributedString = NSMutableAttributedString(string: destructionLabelAttributedText, attributes: [
            .font: AppStyle.CustomFontStyle.Regular.font(withSize: 9.0)!,
            .foregroundColor: UIColor.white,
            .kern: 0.0
            ])
        
        attributedString.addAttribute(.font, value: AppStyle.CustomFontStyle.Bold.font(withSize: 9.0)!,
                                      range: NSRange(location: location, length: length))
        
        return attributedString
    }
    
    func scheduleTimeCountForDestruct() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let remainDays = secondsAgo / day
        let remainHoursInDay = (secondsAgo - remainDays * day) / hour
        let remainMinutesInHour = (secondsAgo - remainDays * day - remainHoursInDay * hour) / minute
        let timeString = formatScheduleDestructionTimeToString(days: abs(remainDays), hours: abs(remainHoursInDay), minutes: abs(remainMinutesInHour))
        return timeString
    }
    
    func formatScheduleDestructionTimeToString(days: Int, hours: Int, minutes: Int) -> String {
        var destructionLabelText = ""
        var dateString = ""
        var daysSuffix = ""
        var hoursSuffix = ""
        
        var daysLastDigit = 0
        
        if days < 10 || days > 19 {
            let daysString = days.description
            daysLastDigit = Int(String(daysString.last!))!
        } else {
            daysLastDigit = days
        }
        
        if daysLastDigit > 0 {
            if daysLastDigit > 1 {
                daysSuffix = Strings.Formatter.manyDays.localized
                if daysLastDigit < 5 {
                    daysSuffix = Strings.Formatter.manyDaysx.localized
                }
            } else {
                daysSuffix = Strings.Formatter.oneDay.localized
            }
            dateString = dateString + String(format: "%d", days) + daysSuffix
        }
        
        var hoursLastDigit = 0
        
        if hours < 10 || hours > 19 {
            let hoursString = hours.description
            hoursLastDigit = Int(String(hoursString.last!))!
        } else {
            hoursLastDigit = hours
        }
        
        if hoursLastDigit > 1 {
            hoursSuffix = Strings.Formatter.manyHours.localized
            if hoursLastDigit < 5 {
                hoursSuffix = Strings.Formatter.manyHoursx.localized
            }
        } else {
            hoursSuffix = Strings.Formatter.oneHour.localized
            if hoursLastDigit < 1 {
                hoursSuffix = Strings.Formatter.manyHours.localized
            }
        }
        
        dateString = dateString + String(format: "%02d", hours) + hoursSuffix
        
        destructionLabelText = destructionLabelText + dateString
        
        DPrint("destructionLabelText:", destructionLabelText)
        return destructionLabelText
    }
    
    func minutesCountForTokenExpiration() -> Int {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let hoursCount = secondsAgo / hour
        let minutesCount = secondsAgo / minute

        DPrint("hoursCount", hoursCount)
        DPrint("minutesCount", minutesCount)
        
        return minutesCount
    }
    
    func hoursCountForTokenExpiration() -> Int {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let hoursCount = secondsAgo / hour
        let minutesCount = secondsAgo / minute
        
        DPrint("hoursCount", hoursCount)
        DPrint("minutesCount", minutesCount)
        
        return hoursCount
    }
    
    func hoursCountFromNow() -> Int {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let hoursCount = secondsAgo / hour
        
        DPrint("hoursCount:", -hoursCount)
        return -hoursCount
    }
    
    func minutesCountFromNow() -> Int {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let minutesCount = secondsAgo / minute
        
        DPrint("minutesCount:", -minutesCount)
        return -minutesCount
    }
}

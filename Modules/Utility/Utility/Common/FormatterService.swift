import Foundation
import CryptoHelperKit
import CoreGraphics
import UIKit

public class FormatterService {
    // MARK: - Constructor
    public init() {}
    
    // MARK: - Hash password
    public func generateSaltFrom(userName: String) -> String {
        let formattedUserName = userName.lowercased().replacingOccurrences( of:"[^a-zA-Z]", with: "", options: .regularExpression)
        var newUserName = formattedUserName
        var newSalt = AppSecurity.SaltPrefix.rawValue
        let rounds = Int(AppSecurity.NumberOfRounds.rawValue)!/newUserName.count + 1
        
        for _ in 0..<rounds {
            newUserName = newUserName + formattedUserName
        }
        newSalt = newSalt + newUserName
        
        let index = newSalt.index(newSalt.startIndex, offsetBy: Int(AppSecurity.NumberOfRounds.rawValue)!)
        newSalt = String(newSalt.prefix(upTo: index))
        return newSalt
    }
    
    public func hash(password: String, salt: String) -> String {
        let hashedPassword = BCryptSwift.hashPassword(password, withSalt: salt) ?? ""
        return hashedPassword
    }
    
    // MARK: - Input String format validation
    public func validateEmailFormat(enteredEmail: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
    
    public func validateNameFormat(enteredName: String) -> Bool {
        let nameFormat = "[A-Z0-9a-z._%+-@]{4,64}"
        let namePredicate = NSPredicate(format:"SELF MATCHES %@", nameFormat)
        return namePredicate.evaluate(with: enteredName)
    }
    
    public func validateFolderNameFormat(enteredName: String) -> Bool {
        let nameFormat = "[A-Z0-9a-z._%+-@ ]{4,64}"//allow whitespaces
        let namePredicate = NSPredicate(format:"SELF MATCHES %@", nameFormat)
        return namePredicate.evaluate(with: enteredName)
    }
    
    public func validateNameLench(enteredName: String) -> Bool {
        return enteredName.isEmpty == false
    }
    
    public func validatePasswordLench(enteredPassword: String) -> Bool {
        return enteredPassword.isEmpty == false
    }
    
    public func comparePasswordsLench(enteredPassword: String, password: String) -> Bool {
        return (enteredPassword.count >= password.count) ? true : false
    }
    
    public func validatePasswordFormat(enteredPassword: String) -> Bool {
        let passwordFormat = "[A-Z0-9a-z._%+-]{1,64}"//"^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,64}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordFormat)
        return passwordPredicate.evaluate(with: enteredPassword)
    }
    
    public func passwordsMatched(choosedPassword: String, confirmedPassword: String) -> Bool {
        if (choosedPassword.count > 0 && confirmedPassword.count > 0) {
            if choosedPassword == confirmedPassword {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    // MARK: - Message String formatter
    public func formatToString(toEmailsArray: [String]) -> String {
        var toEmailsText = Strings.Formatter.toPrefix.localized
        for toEmail in toEmailsArray {
            toEmailsText = toEmailsText + "<" + toEmail + ">,\n"
        }
        if !toEmailsText.isEmpty {
            toEmailsText = String(toEmailsText.dropLast(2))
        }
        return toEmailsText
    }
    
     public func formatFromToString(fromName: String,
                             fromEmail: String,
                             toNamesArray: [String],
                             toEmailsArray: [String],
                             ccArray: [String],
                             bccArray: [String]) -> String {
        
        var toEmailsText = "\n" + Strings.Formatter.toPrefix.localized
        
        for toEmail in toEmailsArray {
            toEmailsText = toEmailsText + "<" + toEmail + ">,\n"
        }
        
        if !toEmailsText.isEmpty {
            toEmailsText = String(toEmailsText.dropLast(2))
        }
        
        var ccText = "\n" + Strings.Formatter.ccPrefix.localized
        
        for carbonCopy in ccArray {
            ccText = ccText + "<" + carbonCopy + ">,\n"
        }
        
        ccText = ccArray.isEmpty == false ? String(ccText.dropLast(2)) : ""

        var bccText = "\n" + Strings.Formatter.bccPrefix.localized
        
        for bcarbonCopy in bccArray {
            bccText = bccText + "<" + bcarbonCopy + ">,\n"
        }
        
        bccText = bccArray.isEmpty == false ? String(bccText.dropLast(2)) : ""

        let textString = Strings.Formatter.fromPrefix.localized + fromName + " <" + fromEmail + ">" + toEmailsText + ccText + bccText
        
        DPrint("textString:", textString)
        return textString
    }
    
    public func formatFromToAttributedString(fromName: String,
                                      fromToText: String,
                                      toNamesArray: [String],
                                      toEmailsArray: [String],
                                      ccArray: [String],
                                      bccArray: [String]) -> NSAttributedString {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = CGFloat(GeneralConstant.PageControlConstant.lineSpaceSizeForFromToText.rawValue)
        
        let font = AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)!
        
        let attributedString = NSMutableAttributedString(string: fromToText, attributes: [
            .font: font,
            .foregroundColor: k_messageCountLabelTextColor,
            .kern: 0.0,
            .paragraphStyle: style
            ])
        
        _ = attributedString.setForgroundColor(textToFind: fromName, color: k_cellTitleTextColor)
        
        for name in toNamesArray {
            _ = attributedString.setForgroundColor(textToFind: name, color: k_cellTitleTextColor)
        }
        return attributedString
    }
    
    // MARK: - Date String formatter
    public func formatReplyDate(date: Date) -> String {
        let dateString = formatDateToStringFull(date: date)
        return dateString
    }
    
    public func formatCreationDate(date: Date,
                            short: Bool,
                            useFullDate: Bool = false) -> String {
        guard !useFullDate else {
            return formatDateToStringMonthDateAndTime(date: date)
        }
        
        var dateString = ""
        
        if let daysCount = calculateDaysCountFromCreate(date: date) {
            if daysCount > 0 {
                if daysCount == 1 {
                    // Yesterday
                    dateString = Strings.Formatter.yesterday.localized
                } else {
                    // 2 or more
                    dateString = short ? formatDateToStringMonthAndDate(date: date) : formatDateToStringMonthDateAndTime(date: date)
                }
            } else {
                // Current day
                dateString = formatDateToStringTime(date: date)
            }
        }
        return dateString
    }
    
    public func formatDestructionDate(date: Date) -> String {
        var dateString = ""
        
        if !Device.IS_IPHONE_5 {
            dateString = dateString + Strings.Formatter.deleteIn.localized
        }
        
        if let daysCount = calculateDaysCountForDestruct(date: date), daysCount > 0 {
            dateString = "\(dateString)\(String(format: "%@", daysCount))\(Strings.Formatter.daySuffix.localized)"
        }
        return dateString
    }
    
    public func formatDeadManDateString(duration: Int, short: Bool) -> NSMutableAttributedString {
        var dateString = ""
        var location = 0
        var length = 5
        
        if !short {
            location = Strings.Formatter.deadMans.localized.count
            dateString = "\(dateString)\(Strings.Formatter.deadMans.localized)"
        }
        
        if duration > 0 {
            if duration > 24 {
                length = 8
                let days = duration / 24
                if days > 10 {
                    length = 9
                }
                dateString = dateString + String(format: "%d", days) + Strings.Formatter.daySuffix.localized
                let hours = duration - (days * 24)
                dateString = dateString + String(format: "%02d", hours) + ":00"
            } else {
                let hours = duration
                dateString = dateString + String(format: "%02d", hours) + ":00"
            }
        } else {
            dateString = dateString + "00:00"
        }
        
        let attributedString = NSMutableAttributedString(string: dateString, attributes: [
            .font: AppStyle.CustomFontStyle.Regular.font(withSize: 9.0)!,
            .foregroundColor: UIColor.white,
            .kern: 0.0
            ])
        
        attributedString.addAttribute(.font, value: AppStyle.CustomFontStyle.Bold.font(withSize: 9.0)!, range: NSRange(location: location, length: length))
        
        return attributedString
    }
    
    public func formatStringToDate(date: String) -> Date? {
        return SharedDateFormatter.shared.date(from: date,
                                               formatter: GeneralConstant.DateFormatStyle.utc.rawValue)
    }
    
    public func formatDestructionTimeStringToDate(date: String) -> Date? {
        return SharedDateFormatter.shared.date(from: date,
                                               formatter: GeneralConstant.DateFormatStyle.utcWithoutSecond.rawValue)
    }
    
    public func formatDestructionTimeStringToDateTest(date: String) -> Date? {
        return formatStringToDate(date: date)
    }
    
    public func formatDeadManDurationToDate(duration: Int) -> Date? {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .hour, value: duration, to: Date())
        return date
    }
    
    public func formatTokenTimeStringToDate(date: String) -> Date? {
        return SharedDateFormatter.shared.date(from: date,
                                               formatter: GeneralConstant.DateFormatStyle.utcWithoutMilliSecond.rawValue)
    }
    
    public func formatDateToStringTime(date: Date) -> String {
        return SharedDateFormatter.shared.string(from: date,
                                                 formatter: GeneralConstant.DateFormatStyle.HHmma.rawValue)
    }
    
    public func formatDateToStringExpirationTime(date: Date) -> String {
        return SharedDateFormatter.shared.string(from: date,
                                                 formatter: GeneralConstant.DateFormatStyle.utc.rawValue)
    }
    
    public func formatDateToStringTimeFull(date: Date) -> String {
        let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
        return SharedDateFormatter.shared.string(from: date,
                                                 formatter: GeneralConstant.DateFormatStyle.HHmmssa.rawValue,
                                                 locale: Locale(identifier: appLang))
    }
    
    public func formatDateToStringMonthAndDate(date: Date) -> String {
        return SharedDateFormatter.shared.string(from: date,
                                                 formatter: GeneralConstant.DateFormatStyle.MMMdd.rawValue)
    }
    
    public func formatDateToStringMonthDateAndTime(date: Date) -> String {
        return SharedDateFormatter.shared.string(from: date,
                                                 formatter: GeneralConstant.DateFormatStyle.MMMddyyyyHHmmssa.rawValue)
    }
    
    public func formatDateToStringFull(date: Date) -> String {
        let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
        return SharedDateFormatter.shared.string(from: date,
                                          formatter: GeneralConstant.DateFormatStyle.EMMMMddyyyy.rawValue,
                                          locale: Locale(identifier: appLang))
    }
    
    public func formatDateToStringDateWithTime(date: Date) -> String {
        return SharedDateFormatter.shared.string(from: date,
                                                 formatter: GeneralConstant.DateFormatStyle.yyyy_MM_dd_HH_mm_ss.rawValue)
    }
    
    public func formatDateToDelayedDeliveryString(date: Date) -> String {
        return SharedDateFormatter.shared.string(from: date,
                                                 formatter: GeneralConstant.DateFormatStyle.EddMMMHHMM.rawValue)
    }
    
    public func formatDateToDelayedDeliveryDateString(date: Date) -> String {
        let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        dateformatter.locale = Locale(identifier: appLang)
        return dateformatter.string(from: date)
    }
    
    public func calculateDaysCountFromCreate(date: Date) -> Int? {
        let calendar = NSCalendar.current
        let date1 = calendar.startOfDay(for: date)
        let date2 = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        if let days = components.day {
            return days
        }
        return 0
    }
    
    public func calculateDaysCountForDestruct(date: Date) -> Int? {
        let calendar = NSCalendar.current
        let date1 = calendar.startOfDay(for: date)
        let date2 = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: date2, to: date1)
        if let days = components.day {
            return days
        }
        return 0
    }
    
    public func calculateMinutesCountFor(date: Date) -> Int? {
        let calendar = NSCalendar.current
        let dateNow = Date()
        let components = calendar.dateComponents([.minute], from: dateNow, to: date)
        if let minutes = components.minute {
            return minutes
        }
        return 0
    }
    
    public func formatSelfShedulerDateToSringForAPIRequirements(date: Date) -> String {
        return SharedDateFormatter.shared.string(from: date,
                                                 formatter: GeneralConstant.DateFormatStyle.YYYYMMddTHHmmssSSSZZZZZ.rawValue,
                                                 timeZone: TimeZone(secondsFromGMT: 0))
    }
    
    public func formatStorageValue(value: Int) -> String {
        var textValue = ""
        if value > 1000 {
            if value > 1000000 {
                //GB
                let valueInGigabytes = value/1024/1024
                textValue = valueInGigabytes.description + " GB"
            } else {
                //MB
                let valueInMegabytes = value/1024
                textValue = valueInMegabytes.description + " MB"
            }
        } else {
            //KB
            textValue = value.description + " KB"
        }
        
        return textValue
    }
    
    public struct Units {
        
        public let bytes: Int64
        
        public var kilobytes: Double {
            return Double(bytes) / 1_024
        }
        
        public var megabytes: Double {
            return kilobytes / 1_024
        }
        
        public var gigabytes: Double {
            return megabytes / 1_024
        }
        
        public init(bytes: Int64) {
            self.bytes = bytes
        }
        
        public func getReadableUnit() -> String {
            
            switch bytes {
            case 0..<1_024:
                return "\(bytes) bytes"
            case 1_024..<(1_024 * 1_024):
                return "\(String(format: "%.2f", kilobytes)) kb"
            case 1_024..<(1_024 * 1_024 * 1_024):
                return "\(String(format: "%.2f", megabytes)) mb"
            case (1_024 * 1_024 * 1_024)...Int64.max:
                return "\(String(format: "%.2f", gigabytes)) gb"
            default:
                return "\(bytes) bytes"
            }
        }
    }
}



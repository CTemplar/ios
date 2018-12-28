//
//  FormatterService.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 08.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import BCryptSwift

class FormatterService
{
    
    //MARK: - Hash password
    
    func generateSaltFrom(userName: String) -> String {
        
        let formattedUserName = userName.lowercased().replacingOccurrences( of:"[^a-zA-Z]", with: "", options: .regularExpression)
        var newUserName = formattedUserName
        
        var newSalt : String = k_saltPrefix
        
        let rounds = k_numberOfRounds/newUserName.count + 1
        
        //print("rounds:", rounds)
        
        for _ in 0..<rounds {
            newUserName = newUserName + formattedUserName
        }
        
        //print("newUserName:", newUserName)
        
        newSalt = newSalt + newUserName
        
        let index = newSalt.index(newSalt.startIndex, offsetBy: k_numberOfRounds)
        newSalt = String(newSalt.prefix(upTo: index))
        
        //print("newSalt subs:", newSalt, "cnt:",  newSalt.count)
        
        return newSalt
    }
    
    func hash(password: String, salt: String) -> String {
        
        var hashedPassword : String
        
        hashedPassword = BCryptSwift.hashPassword(password, withSalt: salt) ?? ""
        /*
        if BCryptSwift.verifyPassword(password, matchesHash: hashedPassword)! {
            print("matched!")
        }*/
        
        return hashedPassword
    }
    
    //MARK: - Input String format validation
    
    func validateEmailFormat(enteredEmail: String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
    
    func validateNameFormat(enteredName: String) -> Bool {
        
        let nameFormat = "[A-Z0-9a-z._%+-]{4,64}"
        let namePredicate = NSPredicate(format:"SELF MATCHES %@", nameFormat)
        return namePredicate.evaluate(with: enteredName)
    }
    
    func validateNameLench(enteredName: String) -> Bool {
        
        if (enteredName.count > 0)  {
            return true
        } else {
            return false
        }
    }
    
    func validatePasswordLench(enteredPassword: String) -> Bool {
        
        if (enteredPassword.count > 0)  {
            return true
        } else {
            return false
        }
    }
    
    func comparePasswordsLench(enteredPassword: String, password: String) -> Bool {
        
        if (enteredPassword.count >= password.count)  {
            return true
        } else {
            return false
        }
    }
    
    func validatePasswordFormat(enteredPassword: String) -> Bool {
        
        let passwordFormat = "[A-Z0-9a-z._%+-]{1,64}"//"^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,64}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordFormat)
        return passwordPredicate.evaluate(with: enteredPassword)
    }
    
    func passwordsMatched(choosedPassword: String, confirmedPassword: String) -> Bool {
        
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
    
    //MARK: - Message String formatter
    
    func formatToString(toEmailsArray: Array<String>) -> String {
        
        var toEmailsText : String = "To: "
        
        for toEmail in toEmailsArray {
            toEmailsText = toEmailsText + "<" + toEmail + ">,\n"
        }
        
        if toEmailsText.count > 0 {
            toEmailsText = String(toEmailsText.dropLast(2))
        }
                
        return toEmailsText
        
    }
    
     func formatFromToString(fromName: String, fromEmail: String, toNamesArray: Array<String>, toEmailsArray: Array<String>, ccArray: Array<String>) -> String {
        
        var toEmailsText : String = "\nTo: "
        
        for toEmail in toEmailsArray {
            toEmailsText = toEmailsText + "<" + toEmail + ">,\n"
        }
        
        if toEmailsText.count > 0 {
            toEmailsText = String(toEmailsText.dropLast(2))
        }
        
        var ccText : String = "\nCC: "
        
        for carbonCopy in ccArray {
            ccText = ccText + "<" + carbonCopy + ">,\n"
        }
        
        if ccArray.count > 0 {
            ccText = String(ccText.dropLast(2))
        }

        let textString = "From: " + fromName + " <" + fromEmail + ">" + toEmailsText + ccText
        
        print("textString:", textString)
        
        return textString
    }
    
    func formatFromToAttributedString(fromName: String, fromToText: String, toNamesArray: Array<String>, toEmailsArray: Array<String>, ccArray: Array<String>) -> NSAttributedString {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = CGFloat(k_lineSpaceSizeForFromToText)
        
        let font : UIFont = UIFont(name: k_latoRegularFontName, size: 14.0)!
        
        let attributedString = NSMutableAttributedString(string: fromToText, attributes: [
            .font: font,
            .foregroundColor: UIColor(white: 0.0, alpha: 0.38),
            .kern: 0.0,
            .paragraphStyle: style
            ])
        
        _ = attributedString.setForgroundColor(textToFind: fromName, color: UIColor(white: 0.0, alpha: 0.87))
        
        for name in toNamesArray {
            _ = attributedString.setForgroundColor(textToFind: name, color: UIColor(white: 0.0, alpha: 0.87))
        }
        
        return attributedString
    }
    
    //MARK: - Date String formatter
    
    func formatReplyDate(date: Date) -> String {
        
        var dateString : String = ""
        
        dateString = formatDateToStringFull(date: date)
        
        return dateString
    }
    
    func formatCreationDate(date: Date) -> String {
        
        var dateString : String = ""
        
        if let daysCount = calculateDaysCountFromCreate(date: date) {

            if daysCount > 0 {
                if daysCount == 1 {
                    //yesterday
                    dateString = "Yesterday"
                } else {
                    //2 or more
                    dateString = formatDateToStringMonthAndDate(date: date)
                }
            } else {
                //current day
                dateString = formatDateToStringTime(date: date)
            }
        }
        
        return dateString
    }
    
    func formatDestructionDate(date: Date) -> String {
        
        var dateString : String = ""
        
        if !Device.IS_IPHONE_5 {
            dateString = dateString + "Delete In "
        }
        
        if let daysCount = calculateDaysCountForDestruct(date: date) {
         
            if daysCount > 0 {
               dateString = dateString + String(format: "%@", daysCount) + "d" //%02d
                
               let timeWithoutDaysDate = Calendar.current.date(byAdding: .day, value: -daysCount, to: Date())!
            }
        }
        
        
        
        return dateString
    }
    
    func formatDeadManDateString(duration: Int, short: Bool) -> NSMutableAttributedString {
        
        var dateString : String = ""
        var location = 0
        var length = 5
        
        if !short {
            dateString = dateString + "Dead mans "
            location = 10
        }
        
        if duration > 0 {
            if duration > 24 {
                length = 8
                
                let days = duration / 24
                
                if days > 10 {
                    length = 9
                }
                
                dateString = dateString + String(format: "%d", days) + "d "
                
                let hours = duration - (days * 24)
                dateString = dateString + String(format: "%02d", hours) + ":00"
            } else {
                let hours = duration
                dateString = dateString + String(format: "%02d", hours) + ":00"
            }
        }
        
        let attributedString = NSMutableAttributedString(string: dateString, attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 9.0)!,
            .foregroundColor: UIColor.white,
            .kern: 0.0
            ])
        
        attributedString.addAttribute(.font, value: UIFont(name: k_latoBoldFontName, size: 9.0)!, range: NSRange(location: location, length: length))
        
        return attributedString
    }
    
    func formatStringToDate(date: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        //2018-10-18T14:03:30.343381Z
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let formattedDate = dateFormatter.date(from: date)
        
        return formattedDate
    }
    
    func formatDestructionTimeStringToDate(date: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        //2018-10-30T21:00:00Z
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SSZ"
        
        let formattedDate = dateFormatter.date(from: date)
        
        return formattedDate
    }
    
    func formatDestructionTimeStringToDateTest(date: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        //"YYYY-MM-dd'T'hh:mm:ss.SSSZZZZZ" //"2018-12-22T10:53:17.000+03:00"
        //2018-12-18T05:18:17.919000Z
        //2018-12-17T22:29:39.619000Z
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let formattedDate = dateFormatter.date(from: date)
        
        return formattedDate
    }
    
    func formatDeadManDurationToDate(duration: Int) -> Date? {
        
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .hour, value: duration, to: Date())
        
        return date
    }
    
    func formatTokenTimeStringToDate(date: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        //2018-10-24 05:51:21 +0000
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let formattedDate = dateFormatter.date(from: date)
        
        return formattedDate
    }
    
    func formatDateToStringTime(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        //dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm a"
        
        let dateString = dateFormatter.string(from:date as Date)
        
        return dateString
    }
    
    func formatDateToStringExpirationTime(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let dateString = dateFormatter.string(from:date as Date)
        
        return dateString
    }
    
    func formatDateToStringTimeFull(date: Date) -> String {
        
        let dateFormatter = DateFormatter()        
        dateFormatter.dateFormat = "HH:mm:ss a"
        
        let dateString = dateFormatter.string(from:date as Date)
        
        return dateString
    }
    
    func formatDateToStringMonthAndDate(date: Date) -> String {
        
        let dateFormatter = DateFormatter()       
        dateFormatter.dateFormat = "MMM dd"
        
        let dateString = dateFormatter.string(from:date as Date)
        
        return dateString
    }
    
    func formatDateToStringFull(date: Date) -> String {
        
        //Thu, November 22, 2018 at 10:10:10 AM
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMMM dd, yyyy"// HH:mm:ss a"
        
        let dateString = dateFormatter.string(from:date as Date)
        
        return dateString
    }
    
    func formatDateToStringDateWithTime(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        
        let dateString = dateFormatter.string(from:date as Date)
        
        return dateString
    }
    
    func formatDateToDelayedDeliveryString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E dd MMM HH:MM"
        
        let dateString = dateFormatter.string(from:date as Date)
        
        return dateString
    }
    
    func formatDateToDelayedDeliveryDateString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E dd MMM HH:mm"
        
        let dateString = dateFormatter.string(from:date as Date)
        
        return dateString
    }
    
    func calculateDaysCountFromCreate(date: Date) -> Int? {
        
        let calendar = NSCalendar.current
        
        let date1 = calendar.startOfDay(for: date)
        let date2 = calendar.startOfDay(for: Date())
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        if let days = components.day {
            return days
        }
        
        return 0
    }
    
    func calculateDaysCountForDestruct(date: Date) -> Int? {
        
        let calendar = NSCalendar.current
        
        let date1 = calendar.startOfDay(for: date)
        let date2 = calendar.startOfDay(for: Date())
        
        let components = calendar.dateComponents([.day], from: date2, to: date1)
        
        if let days = components.day {
            return days
        }
        
        return 0
    }
    
    func calculateMinutesCountFor(date: Date) -> Int? {
        
        let calendar = NSCalendar.current
        
        let dateNow = Date()
        
        let components = calendar.dateComponents([.minute], from: dateNow, to: date)
        
        if let minutes = components.minute {
            return minutes
        }
        
        return 0
    }
    
    func formatSelfShedulerDateToSringForAPIRequirements(date: Date) -> String {
        
        //"2018-12-30T19:00:00.000+00:00" web
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'hh:mm:ss.SSSZZZZZ" //"2018-12-22T10:53:17.000+03:00"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
}

extension Date {
    
    func timeCountForDelivery(short: Bool) -> NSMutableAttributedString {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        
        let remainDays = secondsAgo / day
        
        let remainHoursInDay = (secondsAgo - remainDays * day) / hour
        
        let remainMinutesInHour = (secondsAgo - remainDays * day - remainHoursInDay * hour) / minute
        
        //print("now", Date())
        //print("remainDays", remainDays)
        //print("remainHoursInDay", remainHoursInDay)
        //print("remainMinutesInHour", remainMinutesInHour)
        
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
        
        //print("now", Date())
        //print("remainDays", remainDays)
        //print("remainHoursInDay", remainHoursInDay)
        //print("remainMinutesInHour", remainMinutesInHour)
        
        let timeString = formatDestructionTimeToString(days: abs(remainDays), hours: abs(remainHoursInDay), minutes: abs(remainMinutesInHour), short: short)
        
        return timeString
    }
    
    func formatDestructionTimeToString(days: Int, hours: Int, minutes: Int, short: Bool) -> NSMutableAttributedString {
        
        var destructionLabelAttributedText = ""
        var dateString : String = ""
        var location = 0
        var length = 5
        
        if !short {
            location = 10
            destructionLabelAttributedText = destructionLabelAttributedText + "Delete In "
        }
            
        if days > 0 {
            
            length = 8
            
            if days > 10 {
                length = 9
            }
            
            dateString = dateString + String(format: "%d", days) + "d " //%02d
        }
        
        dateString = dateString + String(format: "%02d:%02d", hours, minutes)
        
        destructionLabelAttributedText = destructionLabelAttributedText + dateString
        
        //print("destructionLabelAttributedText", destructionLabelAttributedText)
        
        let attributedString = NSMutableAttributedString(string: destructionLabelAttributedText, attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 9.0)!,
            .foregroundColor: UIColor.white,
            .kern: 0.0
            ])
        
        attributedString.addAttribute(.font, value: UIFont(name: k_latoBoldFontName, size: 9.0)!, range: NSRange(location: location, length: length))
        
        return attributedString
    }
    
    func formatDelayDeliveryTimeToString(days: Int, hours: Int, minutes: Int, short: Bool) -> NSMutableAttributedString {
        
        var destructionLabelAttributedText = ""
        var dateString : String = ""
        var location = 0
        var length = 5
        
        if !short {
            location = 11
            destructionLabelAttributedText = destructionLabelAttributedText + "Delay time "//"Delete In "
        }
        
        if days > 0 {
            
            length = 8
            
            if days > 10 {
                length = 9
            }
            
            dateString = dateString + String(format: "%d", days) + "d " //%02d
        }
        
        dateString = dateString + String(format: "%02d:%02d", hours, minutes)
        
        destructionLabelAttributedText = destructionLabelAttributedText + dateString
        
        //print("destructionLabelAttributedText", destructionLabelAttributedText)
        
        let attributedString = NSMutableAttributedString(string: destructionLabelAttributedText, attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 9.0)!,
            .foregroundColor: UIColor.white,
            .kern: 0.0
            ])
        
        attributedString.addAttribute(.font, value: UIFont(name: k_latoBoldFontName, size: 9.0)!, range: NSRange(location: location, length: length))
        
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
        var dateString : String = ""
        var daysSuffix: String = ""
        var hoursSuffix: String = ""
        
        if days > 0 {
            
            if days > 1 {
                daysSuffix = " days "
            } else {
                daysSuffix = " day "
            }
            
            dateString = dateString + String(format: "%d", days) + daysSuffix
        }
        
        if hours > 1 {
            hoursSuffix = " hours"
        } else {
            hoursSuffix = " hour"
        }
        
        dateString = dateString + String(format: "%02d", hours) + hoursSuffix
        
        destructionLabelText = destructionLabelText + dateString
        
        print("destructionLabelText:", destructionLabelText)
        
        return destructionLabelText
    }
    
    func minutesCountForTokenExpiration() -> Int {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        
        let hoursCount = secondsAgo / hour
        let minutesCount = secondsAgo / minute

        print("hoursCount", hoursCount)
        print("minutesCount", minutesCount)
        
        return minutesCount
    }
    
    func hoursCountFromNow() -> Int {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        
        let hoursCount = secondsAgo / hour
        
        print("hoursCount:", -hoursCount)
        return -hoursCount
    }
    
    func minutesCountFromNow() -> Int {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        
        let minutesCount = secondsAgo / minute
        
        print("minutesCount:", -minutesCount)
        return -minutesCount
    }
}

extension Data {
    
    var html2AttributedString: NSAttributedString? {
        
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    func sizeData(units: ByteCountFormatter.Units = [.useAll], countStyle: ByteCountFormatter.CountStyle = .file) -> String {
        
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = units
        byteCountFormatter.countStyle = .file
        
        return byteCountFormatter.string(fromByteCount: Int64(count))
    }
}

extension String {
    /*
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    */
    func localized() -> String {
   
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: "", comment: "")
    }
    
    func localized(lang: String) -> String {
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    func localizeWithFormat(arguments: CVarArg...) -> String{
        
        return String(format: self.localized(), arguments: arguments)
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    var html2AttributedString: NSAttributedString? {
        
        return Data(utf8).html2AttributedString
    }
    
    var html2String: String {
        
        return html2AttributedString?.string ?? ""
    }
    
    public var removeHTMLTag: String {
        
        guard let data = self.data(using: .utf8) else {
            return self
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        
        return attributedString.string.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression)
    }
    
    func numberOfLines() -> Int {
    
        var numberOfLines : Int = 0
        
        self.enumerateLines { (str, _) in
            numberOfLines += 1
        }
        
        return numberOfLines
    }
}

extension NSAttributedString {
    
    var trailingNewlineChopped: NSAttributedString {
        if string.hasSuffix("\n") {
            return self.attributedSubstring(from: NSRange(location: 0, length: length - 1))
        } else {
            return self
        }
    }
}

extension NSMutableAttributedString {
    
    public func setAsLink(textToFind: String, linkURL: String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            self.addAttributes(underlineAttribute, range: foundRange)
            return true
        }
        return false
    }
    
    public func setUnderline(textToFind: String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        
        if foundRange.location != NSNotFound {            
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            self.addAttributes(underlineAttribute, range: foundRange)
            return true
        }
        return false
    }
    
    public func setForgroundColor(textToFind: String, color: UIColor) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        
        if foundRange.location != NSNotFound {            
            self.addAttribute(.foregroundColor, value: color, range: foundRange)
            return true
        }
        return false
    }
    
    public func foundRangeFor(lowercasedString: String, textToFind: String) -> NSRange {
        
        let lowercasedTextToFind = textToFind.lowercased()
        
        if let stringRange = lowercasedString.range(of: lowercasedTextToFind) {
            let foundRange = NSRange(stringRange, in: lowercasedString)
            
            if foundRange.location != NSNotFound {
                return foundRange
            }
        }
        
        return NSRange(location: 0, length: 0)
    }
    
    public func setBackgroundColor(range: NSRange, color: UIColor) -> Bool {
        
        if range.location != NSNotFound {
            self.addAttribute(.backgroundColor, value: color, range: range)
            return true
        }
        return false
    }
    
    public func setBackgroundColor(textToFind: String, color: UIColor) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        
        if foundRange.location != NSNotFound {
            self.addAttribute(.backgroundColor, value: color, range: foundRange)
            return true
        }
        return false
    }
    
    public func setFont(textToFind: String, font: UIFont) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        
        if foundRange.location != NSNotFound {           
            self.addAttribute(.font, value: font, range: foundRange)
            return true
        }
        return false
    }
}

extension UITextView {
    
    func autosizeTextFont() {
        
        if (self.text.isEmpty || self.bounds.size.equalTo(CGSize.zero)) {
            return;
        }
        
        let textViewSize = self.frame.size;
        let fixedWidth = textViewSize.width;
        let expectSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        
        var expectFont = self.font
        
        if (expectSize.height > textViewSize.height) {
            
            while (self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height > textViewSize.height) {
                expectFont = self.font!.withSize(self.font!.pointSize - 1)
                self.font = expectFont
            }
        } else {
            
            while (self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height < textViewSize.height) {
                expectFont = self.font
                self.font = self.font!.withSize(self.font!.pointSize + 1)
            }
            
            self.font = expectFont
        }
    }
    
    func disableTextPadding() {
        
        self.contentInset = UIEdgeInsets(top: -8, left: -2, bottom: -8, right: -8)
    }
    
    func numberOfLines() -> Int {
        
        let layoutManager = self.layoutManager
        var numberOfLines : Int = 0
        var index : Int = 0
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var lineRange: NSRange = NSMakeRange(0, 1)
        
        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        
        return numberOfLines
    }
}

extension Array where Element: Hashable {
    
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension URL {
    
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}

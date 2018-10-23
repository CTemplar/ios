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
        
        var newUserName = userName.lowercased()
        
        var newSalt : String = k_saltPrefix
        
        let rounds = k_numberOfRounds/newUserName.count + 1
        
        //print("rounds:", rounds)
        
        for _ in 0..<rounds {
            newUserName = newUserName + userName
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
    
    func validateEmailFormat(enteredEmail:String) -> Bool {
        
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
    
    func validatePasswordFormat(enteredPassword: String) -> Bool {
        
        let passwordFormat = "[A-Z0-9a-z._%+-]{7,64}"//"^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,64}$"
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
    
    //MARK: - Date String formatter
    
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
    
    func formatStringToDate(date: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        //2018-10-18T14:03:30.343381Z
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let formattedDate = dateFormatter.date(from: date)
        
        return formattedDate
    }
    
    func formatDestructionStringToDate(date: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        //2018-10-30T21:00:00Z
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SSZ"
        
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
    
    func formatDateToStringMonthAndDate(date: Date) -> String {
        
        let dateFormatter = DateFormatter()       
        dateFormatter.dateFormat = "MMM dd"
        
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
    
    func calculateTimeCountForDestruct(date: Date) -> Int? {
        
        let calendar = NSCalendar.current
        
        let date1 = calendar.startOfDay(for: date)
        let date2 = calendar.startOfDay(for: Date())
        
        let components = calendar.dateComponents([.hour], from: date2, to: date1)
        
        if let days = components.hour {
            return days
        }
        
        return 0
    }
}

extension Date {
    
    func timeCountForDestruct() -> String {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        
        let remainDays = secondsAgo / day

        let remainHoursInDay = (secondsAgo - remainDays * day) / hour
        
        let remainMinutesInHour = (secondsAgo - remainDays * day - remainHoursInDay * hour) / minute
        
        print("now", Date())
        print("remainDays", remainDays)
        print("remainHoursInDay", remainHoursInDay)
        print("remainMinutesInHour", remainMinutesInHour)
        
        let timeString = formatDestructionTimeToString(days: abs(remainDays), hours: abs(remainHoursInDay), minutes: abs(remainMinutesInHour))
        
        return timeString
    }
    
    func formatDestructionTimeToString(days: Int, hours: Int, minutes: Int) -> String {
        
        var dateString : String = ""
        
        if !Device.IS_IPHONE_5 {
            dateString = dateString + "Delete In "
        }
            
        if days > 0 {
            dateString = dateString + String(format: "%d", days) + "d " //%02d
        }

        dateString = dateString + String(format: "%02d:%02d", hours, minutes) 
        
        print("dateString", dateString)
        
        return dateString
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
}

extension String {
    
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
        
        return attributedString.string.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
    }
}

extension NSMutableAttributedString {
    
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            self.addAttributes(underlineAttribute, range: foundRange)
            return true
        }
        return false
    }
    
    public func setUnderline(textToFind:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        
        if foundRange.location != NSNotFound {            
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            self.addAttributes(underlineAttribute, range: foundRange)
            return true
        }
        return false
    }
    
    public func setForgroundColor(textToFind:String, color: UIColor) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        
        if foundRange.location != NSNotFound {            
            self.addAttribute(.foregroundColor, value: color, range: foundRange)
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
}


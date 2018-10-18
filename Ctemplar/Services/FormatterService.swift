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


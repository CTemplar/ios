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

        let userNameLench = userName.count
        
        var salt : String
        var rounds = 0

        if userNameLench < k_numberOfRounds {
            let newUserName = userName + userName
         //   salt = generateSaltFrom(userName: newUserName)
            rounds = userNameLench
        } else {
            rounds = k_numberOfRounds
        }
        
        rounds = 5
        
        salt = BCryptSwift.generateSaltWithNumberOfRounds(UInt(rounds))
        
        return salt
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
        
        let passwordFormat = "[A-Z0-9a-z._%+-]{8,64}"//"^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,64}$"
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

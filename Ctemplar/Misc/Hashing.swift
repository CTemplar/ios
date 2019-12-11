//
//  Hashing.swift
//  Ctemplar
//
//  Created by romkh on 11.12.2019.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import BCryptSwift
import Foundation

protocol HashingService {
    func generateHashedPassword(for userName: String, password: String, completion: @escaping Completion<String>)
    func generatedSalt(from userName: String) -> String
}

extension HashingService {
    func generateHashedPassword(for userName: String, password: String, completion: @escaping Completion<String>) {
        DispatchQueue.global().async {
            let salt = self.generatedSalt(from: userName)
            let hashed = BCryptSwift.hashPassword(password, withSalt: salt)
            DispatchQueue.main.async {
                if let value = hashed {
                    completion(.success(value))
                } else {
                    completion(.failure(AppError.hashingFailed))
                }
            }
        }
    }
    func generatedSalt(from userName: String) -> String {
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
}


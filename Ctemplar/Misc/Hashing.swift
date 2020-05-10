//
//  Hashing.swift
//  Ctemplar
//
//  Created by romkh on 11.12.2019.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import BCryptSwift
import Foundation

struct CryptoInfo {
    let userPgpKey: UserPGPKey
    let hashedPassword: String
}

protocol HashingService {
    func generateHashedPassword(for userName: String, password: String, completion: @escaping Completion<String>)
    func generatedSalt(from userName: String) -> String
    func generateCryptoInfo(for userName: String, password: String, completion: @escaping Completion<CryptoInfo>)
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
                    completion(.failure(AppError.cryptoFailed))
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
    
    func generateCryptoInfo(for userName: String, password: String, completion: @escaping Completion<CryptoInfo>) {
        DispatchQueue.global(qos: .userInitiated).async {
            var userPGPKey: UserPGPKey?
            var hashedPassword: String?
            let cryptoGroup = DispatchGroup()
            cryptoGroup.enter()
            AppManager.shared.pgpService.generateUserPGPKey(for: userName, password: password) {
                userPGPKey = try? $0.get()
                cryptoGroup.leave()
            }
            cryptoGroup.enter()
            self.generateHashedPassword(for: userName, password: password) {
                hashedPassword = try? $0.get()
                cryptoGroup.leave()
            }
            cryptoGroup.wait()
            DispatchQueue.main.async {
                guard let key = userPGPKey, let hashed = hashedPassword else {
                    completion(.failure(AppError.cryptoFailed))
                    return
                }
                completion(.success(CryptoInfo(userPgpKey: key, hashedPassword: hashed)))
            }
        }
    }
}


import CryptoHelperKit
import Foundation

public struct CryptoInfo {
    public let userPgpKey: UserPGPKey
    public let hashedPassword: String
}

public extension HashingService {
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
    
    func generateCryptoInfo(for userName: String, password: String, completion: @escaping Completion<CryptoInfo>) {
        DispatchQueue.global(qos: .userInitiated).async {
            var userPGPKey: UserPGPKey?
            var hashedPassword: String?
            let cryptoGroup = DispatchGroup()
            cryptoGroup.enter()
            UtilityManager.shared.pgpService.generateUserPGPKey(for: userName, password: password) {
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

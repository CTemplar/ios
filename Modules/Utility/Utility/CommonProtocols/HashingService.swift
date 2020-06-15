import Foundation

public protocol HashingService {
    func generateHashedPassword(for userName: String, password: String, completion: @escaping Completion<String>)
    func generatedSalt(from userName: String) -> String
    func generateCryptoInfo(for userName: String, password: String, completion: @escaping Completion<CryptoInfo>)
}

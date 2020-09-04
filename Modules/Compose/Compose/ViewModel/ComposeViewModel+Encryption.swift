import Utility
import Networking

extension ComposeViewModel {
    func encryptMessageWithOwnPublicKey(message: String) -> String {
        var encryptedMessage = message
        
        if let userKeys = pgpService.getStoredPGPKeys(), !userKeys.isEmpty {
            encryptedMessage = encryptMessage(publicKeys: userKeys, message: message)
        }
        
        return encryptedMessage
    }
    
    func encryptMessage(publicKeys: [PGPKey], message: String) -> String {
        let messageData = pgpService.encodeString(message: message)
        if let encryptedMessage = pgpService.encrypt(data: messageData, keys: publicKeys) {
            DPrint("encryptedMessage:", encryptedMessage)
            return encryptedMessage
        }
        return ""
    }
    
    func setPGPKeysForEncryptionObject(object: EncryptionObject, pgpKey: PGPKey) -> [String: String] {
        var encryptionObjectDictionary: [String: String] = [:]
        var encryptionObject = object
        
        let publicKey = pgpService.exportArmoredPublicKey(pgpKey: pgpKey)
        let privateKey = pgpService.exportArmoredPrivateKey(pgpKey: pgpKey)
            
        encryptionObject.setPGPKeys(publicKey: publicKey ?? "", privateKey: privateKey ?? "")
        
        encryptionObjectDictionary = encryptionObject.toDictionary()
        
        return encryptionObjectDictionary
    }
}

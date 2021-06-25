import Utility
import Networking
import PGPFramework
extension ComposeViewModel {
    func encryptMessageWithOwnPublicKey(message: String) -> String {
        var encryptedMessage = message
        if let userKeys = pgpService.getStoredKeysModel(), !userKeys.isEmpty {
            encryptedMessage = encryptMessage(publicKeys: userKeys, message: message)
        }
        
        return encryptedMessage
    }
    
    func encryptMessage(publicKeys: [KeysModel], message: String) -> String {
        let messageData = pgpService.encodeString(message: message)
        if let encryptedMessage = pgpService.encryptWithKeyModel(data: messageData, keys: publicKeys) {
            DPrint("encryptedMessage:", encryptedMessage)
            return encryptedMessage
        }
        return ""
    }
    
    func encryptMessageForPassword(password: String, message: String) -> String {
        let messageData = pgpService.encodeString(message: message)
        if let encryptedMessage = pgpService.encryptWithFromPassword(data: message, password: password) {
            DPrint("encryptedMessage:", encryptedMessage)
            return encryptedMessage
        }
        return ""
    }
    
    func setPGPKeysForEncryptionObject(object: EncryptionObject, pgpKey: KeysModel) -> [String: String] {
        var encryptionObjectDictionary: [String: String] = [:]
        var encryptionObject = object
        
       // let publicKey = pgpService.exportArmoredPublicKey(pgpKey: pgpKey)
        //let privateKey = pgpService.exportArmoredPrivateKey(pgpKey: pgpKey)
            
        encryptionObject.setPGPKeys(publicKey: pgpKey.publicKey ?? "", privateKey: pgpKey.privateKey ?? "")
        
        encryptionObjectDictionary = encryptionObject.toDictionary()
        
        return encryptionObjectDictionary
    }
}

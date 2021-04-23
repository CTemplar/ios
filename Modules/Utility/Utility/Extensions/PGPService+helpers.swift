import Foundation

public extension PGPService {
    func encryptContact(contactAsJson: String) -> String? {
        if let publicKeys = getStoredKeysModel(), !publicKeys.isEmpty {
            let contactData = encodeString(message: contactAsJson)
            if let encryptedContact = encryptWithKeyModel(data: contactData, keys: publicKeys) {
                DPrint("encryptedContact:", encryptedContact)
                return encryptedContact
            }
        }
        return ""
    }
}

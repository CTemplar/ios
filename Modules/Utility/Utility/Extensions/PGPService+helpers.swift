import Foundation

public extension PGPService {
    func encryptContact(contactAsJson: String) -> String? {
        if let publicKeys = getStoredPGPKeys(), !publicKeys.isEmpty {
            let contactData = encodeString(message: contactAsJson)
            if let encryptedContact = encrypt(data: contactData, keys: publicKeys) {
                DPrint("encryptedContact:", encryptedContact)
                return encryptedContact
            }
        }
        return ""
    }
}

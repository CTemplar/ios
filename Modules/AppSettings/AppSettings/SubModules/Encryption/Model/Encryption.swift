import Utility

public enum EncryptionType {
    case subject
    case contacts
    case attachment
    
    var encryptedlocalized: String {
        switch self {
        case .subject:
            return Strings.EncryptionDecryption.subjectEncrypted.localized
        case .contacts:
            return Strings.EncryptionDecryption.contactsEncrypted.localized
        case .attachment:
            return Strings.EncryptionDecryption.attachmentEncrypted.localized
        }
    }
    
    var decryptedlocalized: String {
        switch self {
        case .subject:
            return Strings.EncryptionDecryption.subjectDecrypted.localized
        case .contacts:
            return Strings.EncryptionDecryption.contactsDecrypted.localized
        case .attachment:
            return Strings.EncryptionDecryption.attachmentDecrypted.localized
        }
    }
}

public struct Encryption: Modelable {
    // MARK: Properties
    let title: String
    var isOn: Bool
    var isEnabled: Bool
    var type: EncryptionType
    
    // MARK: - Constructor
    public init(title: String, isOn: Bool, isEnabled: Bool, type: EncryptionType) {
        self.title = title
        self.isOn = isOn
        self.isEnabled = isEnabled
        self.type = type
    }
    
    // MARK: - Update
    public mutating func update(state: Bool) {
        self.isOn = state
    }
}

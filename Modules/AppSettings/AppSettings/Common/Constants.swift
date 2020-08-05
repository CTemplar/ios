import Utility

let mobileSignatureKey = Domain.main.rawValue + ".mobileSignatureKey"

enum SettingsSection: CaseIterable {
    case general
    case folder
    case security
    case mail
    case aboutTheApp
    case storage
    case logout
    
    var name: String {
        switch self {
        case .general:
            return Strings.AppSettings.generalSettings.localized
        case .folder:
            return Strings.AppSettings.foldersSettings.localized
        case .security:
            return Strings.AppSettings.securitySettings.localized
        case .mail:
            return Strings.AppSettings.mailSettings.localized
        case .aboutTheApp:
            return Strings.AppSettings.aboutSettings.localized
        case .storage:
            return Strings.AppSettings.storageSettings.localized
        case .logout:
            return ""
        }
    }
    
    var rows: [SettingsRow] {
        switch self {
        case .general:
            return [.notifications, .language, .contacts, .whiteOrBlackList, .dashboard]
        case .folder:
            return [.manageFolders]
        case .security:
            return [.password, .recoveryEmail, .encryption]
        case .mail:
            return [.mail, .signature, .mobileSignature, .keys]
        case .aboutTheApp:
            return [.appVersion]
        case .storage:
            return [.storage]
        case .logout:
            return [.logout]
        }
    }
}

enum SettingsRow {
    case notifications
    case language
    case contacts
    case whiteOrBlackList
    case dashboard
    case manageFolders
    case password
    case recoveryEmail
    case encryption
    case mail
    case signature
    case mobileSignature
    case keys
    case appVersion
    case storage
    case logout
}

enum SignatureType {
    case general
    case mobile
}

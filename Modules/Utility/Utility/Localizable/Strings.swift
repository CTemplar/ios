import Foundation

/// Enum cases here are upperCase because they match the rawValue that's in the Localizable.strings file
public enum Strings {
    public enum Button: String, Localizable {
        case closeButton
        case cancelButton
        case logoutButton
        case saveButton
        case applyButton
        case nextButton
        case resetPasswordButton
        case confirmButton
        case addButton
        case changeButton
        case deleteButton
        case encryptButton
        case decryptButton
    }
    
    public enum Formatter: String, Localizable {
        case toPrefix
        case ccPrefix
        case bccPrefix
        case fromPrefix
        case deleteIn
        case yesterday
        case daySuffix
        case deadMans
        case delayTime
        case manyDays
        case manyDaysx
        case oneDay
        case manyHours
        case manyHoursx
        case oneHour
    }
    
    public enum AppError: String, Localizable {
        case downcastFailure
        case hashingFailure
        case conectionError
        case unknownError
    }
    
    public enum Signup: String, Localizable {
        case signupError
        case somethingWentWrong
        case userNameAvailable
        case nameAlreadyExistsError
        case refreshTokenError
        case relogin
        case usernameAndDomain
        case ctemplarEmailAddress
        case choosePasswordPlaceholder
        case confirmPasswordPlaceholder
        case recoveryEmailPlaceholder
        case passwordMust
        case thisIsUsed
        case usernameResetHint
        case usernameResetPlaceholder
        case resetCodePlaceholder
        case newPasswordPlaceholder
        case confirmNewPasswordPlaceholder
        case resetLink
        case confirmResetPassword
        case areYouSure
        case supportDescription
        case supportDescriptionAttr
        case resetPassword
        case weHave
        case recoveryEmailAttr
        case enterIt
        case forgetPass
        case createAccount
        case usernamePlaceholder
        case passwordPlaceholder
        case supportEmailString
        case passwordMatched
        case passwordNotMatched
        case invalidEnteredPassword
        case termsAndConditionsFullText
        case termsAndConditionsPhrase
        case invitationCodePlaceholder
        case invalidEnteredEmail
        case validEnteredEmail
    }
}

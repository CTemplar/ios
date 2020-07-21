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
        case okButton
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
        case error
        case foldersError
        case messagesError
        case mailBoxesError
        case userError
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
        case recoveryEmailAttr
        case enterIt
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
        case minPasswordLengthError
    }
    
    public enum Login: String, Localizable {
        case password
        case forgotPassword
        case login
        case createAccount
        case rememberMe
        case loginError
        
        public enum TwoFactorAuth: String, Localizable {
            case twoFAButtonTitle
            case twoFATitle
            case twoFASecondaryTitle
        }
    }
    
    public enum Banner: String, Localizable {
        case mailSendMessage
        case mailSendingAlert
        case sendMailError
    }
    
    public enum ForgetPassword: String, Localizable {
        case resetCodePlaceholder
        case newPasswordPlaceholder
        case confirmNewPasswordPlaceholder
        case resetLink
        case confirmResetPassword
        case areYouSure
        case resetPassword
        case supportDescription
        case supportDescriptionAttr
        case weHave
        case forgetPass
        case passwordResetError
        case passwordCodeError
        case forgotUserName
        case enterYourEmailAddress
        case emailMyUserName
        case passwordResetSuccessMessage
        case passwordResetSuccessTitle
    }
    
    public enum Logout: String, Localizable {
        case logoutErrorTitle
        case success
        case logoutErrorMessage
        case logoutTitle
        case logoutMessage
    }
    
    public enum ManageFolder: String, Localizable {
        case deleteFolderTitle
        case deleteFolder
        case addFolder
        case selectfolder
        case moveTo
        case noFolders
        case addFolderLimit
        case folderName
        case chooseColor
        case folder
        case folders
    }
    
    public enum Menu: String, Localizable {
        case inbox
        case draft
        case sent
        case outbox
        case starred
        case archive
        case spam
        case trash
        case allMails
        case contacts
        case settings
        case help
        case FAQ
        case logout
        case manageFolders
        case showMoreFolders
        case hideFolders
        case unread
    }
    
    public enum Inbox: String, Localizable {
        case selected
        case inProgress
        case emails
        case email
        case emailsx
        case unread
        case filtered
        case noInboxMessage
        case noFilteredMessage
        case filters
        case moveTo
        case deleteRow
        case messageMovedTo
        
        public enum Filter: String, Localizable {
            case starredFilter
            case unreadFilter
            case attachmentsFilter
        }
        
        public enum MoreAction: String, Localizable {
            case markAsSpam
            case markAsRead
            case markAsUnread
            case moveToTrash
            case moveToArchive
            case moveToInbox
            case moreActions
        }
        
        public enum UndoAction: String, Localizable {
            case undoMarkAsSpam
            case undoMarkAsRead
            case undoMarkAsUnread
            case undoMoveToTrash
            case undoMoveToArchive
            case undoMoveToInbox
        }
        
        public enum Alert: String, Localizable {
            case deleteTitle
            case deleteMessage
        }
    }
    
    public enum AppUpgrade: String, Localizable {
        case upgrade
        case andMore
        case upgradeBig
        case notNow
    }
    
    public enum Search: String, Localizable {
        case noResults
        case search
    }
}

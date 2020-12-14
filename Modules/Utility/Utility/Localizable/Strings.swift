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
        case updateButton
        case yesActionTitle
        case noActionTitle
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
        case fileDownloadError
        case attachmentErrorTitle
        case attachmentErrorMessage
        case contactEncryptionError
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
        case emailPlaceholder
        
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
        case read
        case filtered
        case noInboxMessage
        case noFilteredMessage
        case filters
        case moveTo
        case deleteRow
        case messageMovedTo
        case mailEncryptedMessage
        
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
            case more
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
            case deleteContact
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
    
    public enum InboxViewer: String, Localizable {
        case viewDetails
        case hideDetails
        
        public enum SenderPrefix: String, Localizable {
            case toPrefix
            case ccPrefix
            case bccPrefix
            case fromPrefix
        }
        
        public enum Action: String, Localizable {
            case movingToArchive
            case movingToInbox
            case movingToSpam
            case movingToTrash
            case markingAsUnread
            case markingAsRead
            case actionFailed
            case done
        }
    }
    
    public enum AppSettings: String, Localizable {
        case enableRecoveryEmail
        case typeRecoveryEmail
        case recoveryEmail
        case password
        case language
        case notifications
        case savingContact
        case whiteBlackList
        case dashboard
        case security
        case manageFolders
        case manageSecurity
        case signature
        case mobileSignature
        case defaultText
        case keys
        case aboutUs
        case privacyPolicy
        case terms
        case recoveryEmailUpdatedMessage
        case passwordUpdatedMessage
        case userSignature
        case currentPasswordPlaceholder
        case newPasswordPlaceholder
        case saveContacts
        case selectDefaulfAddress
        case addresses
        case subjectEncryption
        case сontactsEncryption
        case attachmentEncryption
        case enableSignature
        case typeSignature
        case termsAndConditions
        case appVersion
        case generalSettings
        case foldersSettings
        case securitySettings
        case mailSettings
        case aboutSettings
        case storageSettings
        case logoutSettings
        case blockExternalImages
        case htmlEditor
        case featureIsComing
        case saveContactsAlertTitle
        case saveContactsAlertMessage
        case enabled
        case disabled
        case encryptionDisabled
        case insertLink
        case urlRequired
        case title
        case insert
        case infoTitle
        case typeMessage
        case clear
        case done
        case recoveryEmailEnabledAlertMessage
        case addRecoveryEmailTitle
        case addRecoveryEmailMessage
        case recoveryEmailDisabledAlertMessage
        case enable
        case disable
        case changePasswordTitle
        case changePasswordMessage
        case updateAndKeepData
        case updateAndDeleteData
        case changePasswordNotAvailableMessage
        case goToWebVersion
    }
    
    public enum Dashboard: String, Localizable {
        case accountType
        case userName
        case customDomainNumber
        case addressNumber
        case notAvailable
    }
    
    public enum WhiteBlackListContact: String, Localizable {
        case whiteListText
        case blackListText
        case whiteListAttributedText
        case blackListAttributedText
        case addWhiteList
        case addBlackList
        case deleteContactFromBlackList
        case deleteContactFromWhiteList
        case whitelistBlacklist
        case whitelist
        case blacklist
        case addContactW
        case name
        case email
    }
    
    public enum Contacts: String, Localizable {
        case unknownName
        case unknownEmail
        case emailAddress
    }
    
    public enum Language: String, Localizable {
        case languageTitle
    }
    
    public enum EncryptionDecryption: String, Localizable {
        case encryptContactsTitle
        case encryptContacts
        case decryptContactsTitle
        case decryptContacts
        case decryptingContacts
        case allContactsWasEncrypted
        case allContactsWasDecrypted
        case attachmentEncryptionWasEnabled
        case attachmentEncryptionWasDisabled
        case subjectEncrypted
        case subjectDecrypted
        case contactsEncrypted
        case contactsDecrypted
        case attachmentEncrypted
        case attachmentDecrypted
    }
    
    public enum PGPKey: String, Localizable {
        case fingerprint
        case publicKeyDownload
        case privateKeyDownload
    }
    
    public enum Compose: String, Localizable {
        case emailFromPrefix
        case emailToPrefix
        case ccToPrefix
        case bccToPrefix
        case composeEmail
        case SelectDraftOption
        case replyOn
        case wroteBy
        case atTime
        case forwardLine
        case date
        case subject
        case discardDraft
        case saveDraft
        case fromAnotherApp
        case photoLibrary
        case camera
        case newMessage
        case reply
        case relpyAll
        case forward
        case includeAttachments
        case dontIncludeAttachments
        case removeAttachmentAlertTitle
        case removeAttachmentAlertDesc
        case simpleText
        case htmlText
    }
    
    public enum Scheduler: String, Localizable {
        case selfDestructTimer
        case deadManTimer
        case delayedDelivery
        case selfDestructTimerText
        case deadManTimerText
        case delayedDeliveryText
        case setPassword
        case encryptForNon
        case messagePassword
        case expirationTime
        case days
        case hours
        case expireTimeAlert
        case passwordsMustMatch
        case passwordHint
        case encryptedMessagesTo
    }
    
    public enum NetworkError: String, Localizable {
        case networkErrorTitle
        case networkErrorMessage
    }
    
    public enum ForceUpdate: String, Localizable {
        case UpdateAvailableTitle
        case UpdateAvailableMessage
        case GoToStore
    }
}

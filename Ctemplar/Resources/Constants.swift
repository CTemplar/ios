//
//  Constants.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import UIKit
import Foundation
import Utility

// view controllers ID

let k_MainViewControllerID                  = "MainViewController"
let k_SplitViewControllerID                 = "SplitViewController"
let k_LoginViewControllerID                 = "LoginViewController"
let k_SignUpPageViewControllerID            = "SignUpPageViewController"
let k_SignUpPageNameViewControllerID        = "SignUpPageNameViewController"
let k_SignUpPagePasswordViewControllerID    = "SignUpPagePasswordViewController"
let k_SignUpPageEmailViewControllerID       = "SignUpPageEmailViewController"
let k_ForgotPasswordNavigationControllerID  = "ForgotPasswordNavigationController"
let k_ForgotPasswordViewControllerID        = "ForgotPasswordViewController"
let k_ConfirmResetPasswordViewControllerID  = "ConfirmResetPasswordViewController"
let k_ResetPasswordViewControllerID         = "ResetPasswordViewController"
let k_NewPasswordViewControllerID           = "NewPasswordViewController"
let k_ForgorUsernameViewControllerID        = "ForgotUsernameViewController"
let k_InboxNavigationControllerID           = "InboxNavigationController"
let k_InboxViewControllerID                 = "InboxViewController"
let k_InboxSideMenuViewControllerID         = "InboxSideMenuViewController"
let k_ViewInboxEmailViewControllerID        = "ViewInboxEmailViewController"
let k_ComposeViewControllerID               = "ComposeViewController"
let k_SearchViewControllerID                = "SearchViewController"
let k_MoveToViewControllerID                = "MoveToViewController"
let k_ContactsViewControllerID              = "ContactsViewController"
let k_ManageFoldersViewControllerID         = "ManageFoldersViewController"
let k_AddFolderViewControllerID             = "AddFolderViewController"
let k_EditFolderViewControllerID            = "EditFolderViewController"
let k_AddContactViewControllerID            = "AddContactViewController"
let k_SettingsViewControllerID              = "SettingsViewController"
let k_SetPasswordViewControllerID           = "SetPasswordViewController"
let k_SchedulerViewControllerID             = "SchedulerViewController"
let k_RecoveryEmailViewControllerID         = "RecoveryEmailViewController"
let k_ChangePasswordViewControllerID        = "ChangePasswordViewController"
let k_SelectLanguageViewControllerID        = "SelectLanguageViewController"
let k_SavingContactsViewControllerID        = "SavingContactsViewController"
let k_SecurityViewControllerID              = "SecurityViewController"
let k_WhiteBlackListsNavigationControllerID       = "WhiteBlackListsNavigationController"
let k_WhiteBlackListsViewControllerID       = "WhiteBlackListsViewController"
let k_AddContactToWhiteBlackListsViewControllerID       = "AddContactToWhiteBlackListsViewController"
let k_SetMailboxViewControllerID            = "SetMailboxViewController"
let k_SetSignatureViewControllerID          = "SetSignatureViewController"
let k_PgpKeysViewControllerID               = "PgpKeysViewController"
let k_PrivacyAndTermsViewControllerID       = "PrivacyAndTermsViewController"
let k_AboutAsViewControllerID               = "AboutAsViewController"

// view controllers storyboards name

let k_MainStoryboardName                   = "Main"
let k_LoginStoryboardName                  = "Login"
let k_SignUpStoryboardName                 = "SignUp"
let k_ForgotPasswordStoryboardName         = "ForgotPassword"
let k_InboxStoryboardName                  = "Inbox"
let k_InboxSideMenuStoryboardName          = "InboxSideMenu"
let k_ComposeStoryboardName                = "Compose"
let k_SearchStoryboardName                 = "Search"
let k_AboutAsStoryboardName                = "AboutAs"
let k_ContactsStoryboardName               = "Contacts"
let k_ManageFoldersStoryboardName          = "ManageFolders"
let k_AddFolderStoryboardName              = "AddFolder"
let k_EditFolderStoryboardName             = "EditFolder"
let k_MoveToStoryboardName                 = "MoveTo"
let k_ViewInboxEmailStoryboardName         = "ViewInboxEmail"
let k_SettingsStoryboardName               = "Settings"
let k_SetPasswordStoryboardName            = "SetPassword"
let k_SchedulerStoryboardName              = "Scheduler"
let k_RecoveryEmailStoryboardName          = "RecoveryEmail"
let k_ChangePasswordStoryboardName         = "ChangePassword"
let k_SelectLanguageStoryboardName         = "SelectLanguage"
let k_SavingContactsStoryboardName         = "SavingContacts"
let k_SecurityStoryboardName               = "Security"
let k_WhiteBlackListsStoryboardName        = "WhiteBlackLists"
let k_AddContackToWhiteBlackListsStoryboardName        = "AddContactToWhiteBlackList"
let k_SetMailboxStoryboardName             = "SetMailbox"
let k_SetSignatureStoryboardName           = "SetSignature"
let k_PGPKeysStoryboardName                = "PgpKeys"
let k_PrivacyAndTermsStoryboardName        = "PrivacyAndTerms"
let k_AddContactStoryboardName             = "AddContact"
let k_DashboardStoryboardName              = "Dashboard"

let k_InboxMessageTableViewCellXibName     = "InboxMessageTableViewCell"
let k_InboxFilterViewXibName               = "InboxFilter"
let k_MoreActionsViewXibName               = "MoreActions"
let k_SideMenuTableSectionHeaderViewXibName               = "SideMenuTableSectionHeader"
let k_SideMenuTableViewCellXibName         = "SideMenuTableViewCell"
let k_SideMenuTableManageFolderXibName     = "SideMenuTableManageFoldersCell"
let k_CustomFolderCellXibName              = "CustomFolderTableViewCell"
let k_MoveToFolderCellXibName              = "MoveToFolderTableViewCell"
let k_SearchCellXibName                    = "SearchTableViewCell"
let k_ContactCellXibName                   = "ContactTableViewCell"
let k_ChildMessageCellXibName              = "ChildMessageTableViewCell"
let k_ChildMessageExpandedCellXibName      = "ChildMessageExpandedTableViewCell"
let k_ChildMessageExpandedWithAttachmentCellXibName      = "ChildMessageExpandedWithAttachmentTableViewCell"
let k_UserMailboxCellXibName               = "UserMailboxTableViewCell"
let k_UserMailboxBigCellXibName            = "UserMailboxBigTableViewCell"
let k_AttachmentCollcetionViewCellXibName  = "AttachmentCollcetionViewCell"
let k_AttachmentViewXibName                = "Attachment"
let k_SettingsBaseTableViewCellXibName     = "SettingsBaseTableViewCell"
let k_SettingsStorageTableViewCellXibName  = "SettingsStorageTableViewCell"
let k_UpgradeToPrimeViewXibName            = "UpgradeToPrime"

// cell identifier

let k_InboxMessageTableViewCellIdentifier       = "inboxMessageTableViewCellIdentifier"
let k_SideMenuTableSectionHeaderViewIdentifier  = "sideMenuTableSectionHeaderViewIdentifier"
let k_SideMenuTableManageFolderCellIdentifier   = "sideMenuTableManageFolderCellIdentifier"
let k_SideMenuTableViewCellIdentifier           = "sideMenuTableViewCellIdentifier"
let k_CustomFolderTableViewCellIdentifier       = "customFolderTableViewCellIdentifier"
let k_MoveToFolderTableViewCellIdentifier       = "moveToFolderTableViewCellIdentifier"
let k_SearchTableViewCellIdentifier             = "searchTableViewCellIdentifier"
let k_ContactTableViewCellIdentifier            = "contactTableViewCellIdentifier"
let k_ChildMessageTableViewCellIdentifier       = "childMessageTableViewCellIdentifier"
let k_ChildMessageExpandedTableViewCellIdentifier       = "childMessageExpandedTableViewCellIdentifier"
let k_ChildMessageExpandedWithAttachmentTableViewCellIdentifier       = "childMessageExpandedWithAttachmentTableViewCellIdentifier"
let k_UserMailboxTableViewCellIdentifier        = "userMailboxTableViewCellIdentifier"
let k_UserMailboxBigTableViewCellIdentifier        = "userMailboxBigTableViewCellIdentifier"
let k_AttachmentCollcetionViewCellIdentifier    = "attachmentCollcetionViewCellIdentifier"
let k_SettingsBaseTableViewCellIdentifier       = "settingsBaseTableViewCellIdentifier"
let k_SettingsAppVersionTableViewCellIdentifier         = "settingsAppVersuinCellIdentifier"
let k_SettingsStorageTableViewCellIdentifier       = "settingsStorageTableViewCellIdentifier"
let k_SettingsDashboardTableViewCellIdentifier     = "settingsDashboardTableViewCellIdentifier"

// view controllers iPad storyboards name

let k_MainStoryboardName_iPad              = "Main-iPad"
let k_SplitStoryboardName                  = "SplitiPad"
let k_LoginStoryboardName_iPad             = "Login-iPad"
let k_SignUpStoryboardName_iPad            = "SignUp-iPad"
let k_ForgotPasswordStoryboardName_iPad    = "ForgotPassword-iPad"
let k_AboutAsStoryboardName_iPad           = "AboutAs-iPad"
let k_InboxFilterViewXibName_iPad          = "InboxFilter-iPad"
let k_AddFolderStoryboardName_iPad         = "AddFolder-iPad"


// notifications

let k_updateUserDataNotificationID          = "UpdateUserDataNotificationIdentifier"
let k_updateUserSettingsNotificationID      = "UpdateUserSettingsNotificationIdentifier"
let k_updateInboxMessagesNotificationID     = "updateInboxMessagesNotification"
let k_attachUploadUpdateNotificationID      = "attachUploadUpdateNotificationIdentifier"
let k_reloadViewControllerNotificationID    = "ReloadViewControllerNotificationIdentifier"
let k_reloadViewControllerDataSourceNotificationID    = "ReloadViewControllerDataSourceNotificationIdentifier"
let k_updateCustomFolderNotificationID = "UpdateCustomFoldersNotificationIdentifier"
let k_updateMessagesReadCountNotificationID = "updateMessagesReadCountNotification"

//size constants

let k_pageControlBottomOffset           = 30.0
let k_pageControlDotSize                = 8.0

let k_signUpPageKeyboardOffsetSmall     = 32.0
let k_signUpPageKeyboardOffsetMedium    = 64.0
let k_signUpPageKeyboardOffsetBig       = 96.0
let k_signUpPageKeyboardOffsetLarge     = 160.0
let k_signUpPageKeyboardOffsetExtraLarge     = 210.0
let k_KeyboardHeight                    = 216.0


let k_signUpPageKeyboardOffsetiPadBig   = 116.0
let k_signUpPageKeyboardOffsetiPadLarge = 180.0
let k_signUpPageKeyboardOffsetiPadExtraLarge     = 230.0

let k_setPasswordKeyboardOffset         = 80.0
let k_addContactKeyboardOffset          = 71.0

let k_triangleOffset                    = 16.0 + 5.0 + 5.0
let k_navBarButtonSize                  = 32.0

let k_rightSideWidth            : CGFloat = 120.0

let k_isSelectedImageTrailing   : CGFloat = 12.0
let k_isSelectedImageWidth      : CGFloat = 22.0

let k_countLabelWidth           : CGFloat = 28.0
let k_countLabelTrailing        : CGFloat = 6.0

let k_dotImageWidth             : CGFloat = 6.0
let k_dotImageTrailing          : CGFloat = 6.0

let k_deleteLabelWidth          : CGFloat = 85.0 //72.0
let k_deleteLabelSEWidth        : CGFloat = 45.0 //30.0

let k_folderNameLabelWidth      : CGFloat = 50.0
let k_folderNameLabelMaxWidth   : CGFloat = 80.0
let k_folderNameLabelOffset     : CGFloat = 12.0

let k_inboxFilterViewCenterY    : CGFloat = 430.0

let k_rightOffsetForSubjectLabel : CGFloat = 116.0//126

let k_sideMenuSectionHeaderHeight  : CGFloat = 49
let k_sideMenuSeparatorHeight      : CGFloat = 1

let k_settingsHeaderViewHeight     : CGFloat = 40
let k_logoutHeaderViewHeight       : CGFloat = 50

let k_moreActionsButtonsViewFullContstraint   : CGFloat = 206
let k_moreActionsButtonsViewMiddleContstraint : CGFloat = 154
let k_moreActionsButtonsViewSmallContstraint  : CGFloat = 102
let k_moreActionsButtonHeightConstraint       : CGFloat = 50

let k_fromToViewMinHeight       : CGFloat = 70.0//94.0
let k_fromToHeaderMinHeight     : CGFloat = 146.0
let k_dateLabelOffsetHeight     : CGFloat = 52.0

let k_InsetsForFromTo           : CGFloat = 26.0
let k_lineSpaceSizeForFromToText    = 10
let k_lineHeightForFromToText   : CGFloat = 26.0
let k_lineHeightForMessageText  : CGFloat = 24.0

let k_contactsBottomBarHeight       : CGFloat = 49.0
let k_contactsSelectAllBarHeight    : CGFloat = 50.0

let k_expandDetailsButtonWidth      : CGFloat = 44.0
let k_emailToTextViewLeftOffset     : CGFloat = 16.0
let k_emailToTextViewTopOffset      : CGFloat = 9.0

let k_composeTableViewTopOffset     : CGFloat = 45.0

let k_messageTextViewTopOffset      : CGFloat = 10.0

let k_messageEditorThresholdHeight  : CGFloat = 100.0

let k_attachmentViewHeight          : CGFloat = 44.0
let k_attachmentViewTopOffset       : CGFloat = 25.0
let k_attachmentsInterSpacing       : CGFloat = 8.0

let k_iphoneSEBottomButtonsOffset   : CGFloat = 222.0
let k_iphoneAllBottomButtonsOffset  : CGFloat = 277.0
let k_iPadBottomButtonsOffset       : CGFloat = 20.0

let k_settingsBaseCellHeight        : CGFloat = 50.0
let k_settingsStorageCellHeight     : CGFloat = 78.0

let k_plusImageWidth                : CGFloat = 20.0
let k_addButtonLeftOffet            : CGFloat = 10.0

//images

let k_eyeOffIconImageName           = "EyeIcon"
let k_eyeOnIconImageName            = "EyeOnIcon"

let k_darkEyeOffIconImageName       = "DarkEyeIcon"
let k_darkEyeOnIconImageName        = "DarkEyeOnIcon"

let k_checkBoxUncheckedImageName    = "roundDark"
let k_checkBoxSelectedImageName     = "checkedBoxDark"
let k_roundSelectedImageName        = "selectedRoundDark"

let k_composeImageName              = "ComposeButton"
let k_composeRedImageName           = "ComposeRedButton"
let k_menuImageName                 = "MenuButton"
let k_searchImageName               = "SearchButton"
let k_filterImageName               = "FilterButton"
let k_blackFilterImageName          = "blackFilterButton"

let k_darkBackArrowImageName        = "BackArrowDark"

let k_garbageImageName              = "trashMessage"
let k_spamImageName                 = "spamMessage"
let k_moveImageName                 = "moveMessage"
let k_moreImageName                 = "moreMessage"

let k_unreadImageName               = "unreadMessage"

let k_whiteGarbageImageName         = "whiteTrash"
let k_whiteSpamImageName            = "whiteSpam"
let k_witeUnreadImageName           = "whiteUnread"
let k_witeMoveToImageName           = "whiteMoveTo"

let k_starOnImageName               = "StarOn"
let k_starOffImageName              = "StarOff"
let k_starOnBigImageName            = "StarOnBig"
let k_starOffBigImageName           = "StarOffBig"
let k_secureOnImageName             = "SecureOn"
let k_secureOffImageName            = "SecureOff"

let k_folderIconImageName          = "folderIcon"
let k_labelIconImageName           = "labelIcon"

let k_darkFoldersIconImageName      = "darkFoldersIcon"
let k_darkLabelsIconImageName       = "darkLabelsIcon"

let k_darkAllMailsIconImageName     = "darkAllMails"
let k_darkArchiveIconImageName      = "darkArchive"
let k_darkDraftIconImageName        = "darkDraft"
let k_darkInboxIconImageName        = "darkInbox"
let k_darkSentIconImageName         = "darkSent"
let k_darkFAQIconImageName          = "darkFAQ"
let k_darkOutboxIconImageName       = "darkOutbox"
let k_darkSpamIconImageName         = "darkSpam"
let k_darkStarIconImageName         = "darkStar"
let k_darkTrashIconImageName        = "darkTrash"

let k_darkContactIconImageName      = "darkContact"
let k_darkSettingsIconImageName     = "darkSettings"
let k_darkHelpconImageName          = "darkHelp"
let k_darkExitIconImageName         = "darkLogout"

let k_darkCrossIconImageName        = "darkCross"
let k_redCheckIconImageName         = "redCheck"

let k_emptyInboxIconImageName         = "EmptyInboxIcon"
let k_emptyFilterInboxIconImageName   = "EmptyFilterInboxIcon"

let k_plusButtonIconImageName       = "PlusButton"

let k_darkPlusIconImageName         = "DarkPlus"
let k_redMinusIconImageName         = "RedMinus"

let k_darkPlusBigIconImageName      = "DarkPlusBig"
let k_redMinusBigIconImageName      = "RedMinusBig"

let k_downArrowImageName            = "downArrow"
let k_upArrowImageName              = "upArrow"

let k_attachImageName               = "Attach"
let k_attachApliedImageName         = "AttachAplied"

let k_deadManImageName              = "deadMan"
let k_deadManApliedImageName        = "deadManAplied"

let k_delayedDeliveryImageName      = "delayedDelivery"
let k_delayedDeliveryApliedImageName              = "delayedDeliveryAplied"

let k_encryptImageName              = "encrypt"
let k_encryptApliedImageName        = "encryptAplied"

let k_selfDestructedImageName       = "selfDestructed"
let k_selfDestructedApliedImageName              = "selfDestructedAplied"

let k_selectedColorImageName        = "SelectedColor"

let k_redSelectedImageName          = "RedSelection"


// fonts

let k_latoRegularFontName = "Lato-Regular"
let k_latoBoldFontName    = "Lato-Bold"
let k_unreadMessageSenderFont = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.semibold)
let k_readMessageSenderFont = UIFont.systemFont(ofSize: 16.0)
let k_unreadMessageSubjectFont = UIFont(name: "Lato-Bold", size: 14.0)
let k_readMessageSubjectFont = UIFont(name: "Lato-Regular", size: 14.0)

// other
let k_contactPageLimit = 20
let k_pageLimit = 30
let k_firstLoadPageLimit = 10
let k_firstLoadPageLimit_iPad = 20
let k_offsetForLast = 5

let k_numberOfRounds               = 29
let k_saltPrefix                   = "$2a$10$"

let k_keyringFileName              = "keyring.gpg"
let k_tempFileName                 = "tempFile"

let k_privacyURL                   = "https://ctemplar.com/privacy"
let k_termsURL                     = "https://ctemplar.com/terms"
let k_mainSiteURL                  = "https://ctemplar.com/"
let k_upgradeURL                   = "https://ctemplar.com/pricing"
let k_faqURL                       = "https://ctemplar.com/faqs/"
let k_supportURL                   = "support@ctemplar.com."
let k_FAQURL                       = "https://ctemplar.com/faqs/"

let k_signature_decoding_issue = "error decoding signature."

let k_firstCharsForHeader          = 50
let k_firstCharsForEncryptdHeader  = 5

let k_tokenHoursExpiration         = 120
let k_tokenMinutesExpiration       = 7200
let k_tokenHoursRefresh            = 1920

let k_undoActionBarShowingSecs     = 5.0

let k_numberOfCustomFoldersShowing = 3
let k_customFoldersLimitForNonPremium = 5

let k_colorButtonsTag = 200

let k_mainDomain = "ctemplar.com"
let k_devMainDomain = "dev.ctemplar.net"
let k_devOldDomain = "dev.ctemplar.com"

let k_platform = "ios"

// UserDefaults

let k_mobileSignatureKey = k_mainDomain + ".mobileSignatureKey"

enum InboxSideMenuOptionsName: String {
    case inbox            = "inbox"
    case draft            = "draft"
    case sent             = "sent"
    case outbox           = "outbox"
    case starred          = "starred"
    case archive          = "archive"
    case spam             = "spam"
    case trash            = "trash"
    case allMails         = "allMails"
    case contacts         = "contacts"
    case settings         = "settings"
    case help             = "help"
    case FAQ              = "FAQ"
    case logout           = "logout"
    case manageFolders    = "manageFolders"    
}

enum MessagesFoldersName: String, CaseIterable {
    case inbox            = "inbox"
    case draft            = "draft"
    case sent             = "sent"    
    case outbox           = "outbox"
    case starred          = "starred"
    case archive          = "archive"
    case spam             = "spam"
    case trash            = "trash"
    case outboxSD         = "outbox_self_destruct_counter"
    case outboxDD         = "outbox_delayed_delivery_counter"
    case outboxDM         = "outbox_dead_man_counter"
}

enum InboxCellButtonsIndex: Int {
    case right = 0
    case middle
    case left
}

enum InboxFilterButtonsTag: Int, CaseIterable {
    case starred          = 202
    case unread           = 203
    case withAttachment   = 204
}

enum InboxFilterImagesTag: Int, CaseIterable {
    case starred          = 301
    case unread           = 302
    case withAttachment   = 303
}

enum InboxFilterLablesTag: Int, CaseIterable {
    case starred = 401
    case unread = 402
    case withAttachment = 403
}

enum InboxFilterViewButtonsTag: Int {
    case clearAllButton = 205
    case cancelButton = 206
    case applyButton = 207
}

enum SideMenuSectionIndex: Int {
    case mainFolders = 0
    case options
    case manageFolders
    case customFolders
    case sectionsCount
}

enum MoreViewButtonsTag: Int, CaseIterable {
    case cancel = 401
    case bottom = 402
    case middle = 403
    case upper = 404
}

enum MoreActionsTitles: String, CaseIterable {
    case markAsSpam = "markAsSpam"
    case markAsRead = "markAsRead"
    case markAsUnread = "markAsUnread"
    case moveToTrach = "moveToTrash"
    case moveToArchive = "moveToArchive"
    case moveToInbox = "moveToInbox"
    case emptyFolder = "emptyFolder"
    case cancel = "cancel"
}

enum ActionsIndex: Int, CaseIterable {
    case markAsSpam = 1
    case markAsRead
    case markAsStarred
    case moveToTrach
    case moveToArchive
    case moveToInbox
    case moveTo
    case delete
    case noAction
}

enum DocumentsExtension: String, CaseIterable {
    case doc       = "doc"
    case pdf       = "pdf"
    case png       = "png"
    case jpg       = "jpg"
}

enum ComposeSubViewTags: Int {
    case emailToTextViewTag  = 200
    case ccToTextViewTag     = 300
    case bccToTextViewTag    = 400
    case attachmentsViewTag  = 500
}

enum AnswerMessageMode: String {
    case newMessage = "New Message"
    case reply      = "Reply"
    case replyAll   = "Reply All"
    case forward    = "Forward"
}

enum SchedulerMode: String {
    case selfDestructTimer = "Self-destructing Timer"
    case deadManTimer      = "Dead Man's Timer"
    case delayedDelivery   = "Delayed delivery"
}

enum SettingsSectionsName: String, CaseIterable {
    case general = "generalSettings"
    case folders = "foldersSettings"
    case security = "securitySettings"
    case mail = "mailSettings"
    case about = "aboutSettings"
    case storage = "storageSettings"
    case logout = "logoutSettings"
}

enum SettingsSections: Int, CaseIterable {
    case general = 0
    case folders
    case security
    case mail
    case about
    case storage
    case logout
}

enum SettingsGeneralSection: Int, CaseIterable {
    case notification = 0
    case language
    case contacts
    case whiteBlackList
    case dashboard
}

enum SettingsFoldersSection: Int, CaseIterable {
    case folder = 0
}

enum SettingsSecuritySection: Int, CaseIterable {
    case password = 0
    case recovery
    case encryption
}

enum SettingsMailSection: Int, CaseIterable {
    case mail = 0
    case signature
    case mobileSignature
    case keys
}

enum SettingsAboutSection: Int, CaseIterable {
    case appVersion = 0
}

enum TextControllerMode: Int, CaseIterable {
    case privacyPolicy = 0
    case termsAndConditions
}

enum Languages: Int, CaseIterable {
    case english            = 0
    case russian            = 1
    case french             = 2
    case slovak             = 3
}

enum LanguagesName: String {
    case english            = "English"
    case russian            = "Русский"
    case french             = "Français"
    case slovak             = "Slovenský"
}

enum LanguagesBundlePrefix: String {
    case english            = "en"
    case russian            = "ru"
    case french             = "fr"
    case slovak             = "sk"
}

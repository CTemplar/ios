//
//  Constants.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit
import Foundation

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
let k_PrivacyAndTermsStoryboardName        = "PrivacyAndTerms"
let k_AddContactStoryboardName             = "AddContact"

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
// colors

let k_lightRedColor: UIColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 0.2)
let k_redColor: UIColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)

let k_sideMenuColor: UIColor = UIColor(red: 23.0/255.0, green: 50.0/255.0, blue: 77.0/255.0, alpha: 1.0)
let k_sideMenuSeparatorColor: UIColor = UIColor(red: 23.0/255.0, green: 50.0/255.0, blue: 77.0/255.0, alpha: 0.1)
let k_sideMenuFadeColor: UIColor = UIColor(red: 2.0/255.0, green: 13.0/255.0, blue: 25.0/255.0, alpha: 0.56)
let k_sideMenuTextFadeColor: UIColor = UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 0.4)

let k_urlColor: UIColor = UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
let k_lightGrayColor: UIColor = UIColor(white: 0.0, alpha: 0.54)

let k_emailToColor: UIColor = UIColor(white: 158.0 / 255.0, alpha: 1.0)
let k_emailToInputColor: UIColor = UIColor(red: 9.0 / 255.0, green: 31.0 / 255.0, blue: 53.0 / 255.0, alpha: 0.5)

let k_lightGrayTextColor: UIColor = UIColor(red: 147.0 / 255.0, green: 145.0 / 255.0, blue: 145.0 / 255.0, alpha: 1.0)

let k_mainInboxColor: UIColor = UIColor(red: 242.0 / 255.0, green: 240.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
let k_foundTextBackgroundColor: UIColor = UIColor(red: 217.0 / 255.0, green: 235.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)

let k_whiteColor: UIColor = UIColor(red: 250.0 / 255.0, green: 251.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)
let k_selectedFolderColor: UIColor = UIColor(red: 18.0 / 255.0, green: 45.0 / 255.0, blue: 71.0 / 255.0, alpha: 0.1)

let k_readMessageColor : UIColor = UIColor(white: 245/255, alpha: 1.0)

let k_unreadMessageColor : UIColor = UIColor(white: 1.0, alpha: 1.0)

let k_actionMessageColor : UIColor = UIColor(red: 9.0 / 255.0, green: 31.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)

let k_contactsBarTintColor : UIColor = UIColor(red: 44.0 / 255.0, green: 62.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
let k_passwordBarTintColor : UIColor = UIColor(red: 44.0 / 255.0, green: 62.0 / 255.0, blue: 80.0 / 255.0, alpha: 0.87)

let k_mainFolderTextColor : UIColor = UIColor(red: 9.0 / 255.0, green: 31.0 / 255.0, blue: 53.0 / 255.0, alpha: 0.5)

let k_orangeColor : UIColor = UIColor(red: 255.0 / 255.0, green: 170.0 / 255.0, blue: 14.0 / 255.0, alpha: 1.0)
let k_greenColor : UIColor = UIColor(red: 0.0 / 255.0, green: 116.0 / 255.0, blue: 33.0 / 255.0, alpha: 1.0)

let k_blueColor : UIColor = UIColor(red: 52.0 / 255.0, green: 152.0 / 255.0, blue: 219.0 / 255.0, alpha: 1.0)

let k_docColor : UIColor = UIColor(red: 0.0 / 255.0, green: 150.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0)
let k_pdfColor : UIColor = UIColor(red: 204.0 / 255.0, green: 75.0 / 255.0, blue: 76.0 / 255.0, alpha: 1.0)
let k_pngColor : UIColor = UIColor(red: 101.0 / 255.0, green: 156.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
let k_jpgColor : UIColor = UIColor(red: 19.0 / 255.0, green: 160.0 / 255.0, blue: 133.0 / 255.0, alpha: 1.0)
let k_otherColor : UIColor = UIColor(red: 148.0 / 255.0, green: 165.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)

let k_fileNameColor : UIColor = UIColor(red: 90.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)

let k_settingHeaderLineColor: UIColor = UIColor(red: 235.0 / 255.0, green: 235.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0)

let k_mailboxTextColor: UIColor = UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 1.0)

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

let k_garbageImageName              = "GarbageButton"
let k_spamImageName                 = "SpamButton"
let k_moveImageName                 = "MoveButton"
let k_moreImageName                 = "MoreButton"

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
let k_unreadMEssageSubjectFont = UIFont(name: "Lato-Bold", size: 14.0)
let k_readMEssageSubjectFont = UIFont(name: "Lato-Regular", size: 14.0)

// other
let k_contactPageLimit = 20
let k_pageLimit = 30
let k_firstLoadPageLimit = 10
let k_offsetForLast = 5

let k_numberOfRounds               = 29
let k_saltPrefix                   = "$2a$10$"

let k_keyringFileName              = "keyring.gpg"
let k_tempFileName                 = "tempFile"

let k_privacyURL                   = "https://ctemplar.com/privacy"
let k_termsURL                     = "https://ctemplar.com/terms"
let k_mainSiteURL                  = "https://ctemplar.com/"
let k_upgradeURL                   = "https://ctemplar.com/pricing"
let k_supportURL                   = "support@ctemplar.com."

let k_firstCharsForHeader          = 50
let k_firstCharsForEncryptdHeader  = 5

let k_tokenHoursExpiration         = 2
let k_tokenMinutesExpiration       = 170
let k_tokenHoursRefresh            = 47

let k_undoActionBarShowingSecs     = 5.0

let k_numberOfCustomFoldersShowing = 3
let k_customFoldersLimitForNonPremium = 3

let k_colorButtonsTag = 200

let k_mainDomain = "ctemplar.com"
let k_devMainDomain = "dev.ctemplar.com"

let k_platform = "ios"

// UserDefaults

let k_mobileSignatureKey = k_mainDomain + ".mobileSignatureKey"

enum InboxSideMenuOptionsName: String {
    /*
    case inbox            = "Inbox"
    case draft            = "Draft"
    case sent             = "Sent"
    case outbox           = "Outbox"
    case starred          = "Starred"
    case archive          = "Archive"
    case spam             = "Spam"
    case trash            = "Trash"
    case allMails         = "All Mails"
    case contacts         = "Contacts"
    case settings         = "Settings"
    case help             = "Help"
    case logout           = "Logout"
    case manageFolders    = "Manage Folders"*/
    
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
    //case foldersCount     = "foldersCount"
    case outboxSD         = "outbox_self_destruct_counter"
    case outboxDD         = "outbox_delayed_delivery_counter"
    case outboxDM         = "outbox_dead_man_counter"
}

enum InboxCellButtonsIndex: Int {
    
    case right           = 0
    case middle          = 1
    case left            = 2
}

enum InboxFilterButtonsTag: Int, CaseIterable {
    
    //case all              = 201
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
    
    case starred          = 401
    case unread           = 402
    case withAttachment   = 403
}

enum InboxFilterViewButtonsTag: Int {
    
    case clearAllButton   = 205
    case cancelButton     = 206
    case applyButton      = 207
}

enum SideMenuSectionIndex: Int {
    
    case mainFolders      = 0
    case options          = 1
    case manageFolders    = 2
    case customFolders    = 3
    case sectionsCount    = 4
}

enum MoreViewButtonsTag: Int, CaseIterable {
    
    case cancel           = 401
    case bottom           = 402
    case middle           = 403
    case upper            = 404
}

enum MoreActionsTitles: String, CaseIterable {
    
    case markAsSpam       = "markAsSpam"
    case markAsRead       = "markAsRead"
    case markAsUnread     = "markAsUnread"
    //case markAsStarred    = ""
    case moveToTrach      = "moveToTrash"
    case moveToArchive    = "moveToArchive"
    case moveToInbox      = "moveToInbox"
    //case moveTo           = ""
    case emptyFolder      = "emptyFolder"
    case cancel           = "cancel"
 
}

enum ActionsIndex: Int, CaseIterable {

    case markAsSpam       = 1
    case markAsRead       = 2
    case markAsStarred    = 3
    case moveToTrach      = 4
    case moveToArchive    = 5
    case moveToInbox      = 6
    case moveTo           = 7
    case delete           = 8
    case noAction         = 9
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
    
    case general           = "generalSettings"
    case folders           = "foldersSettings"
    case security          = "securitySettings"
    case mail              = "mailSettings"
    case about             = "aboutSettings"
    case storage           = "storageSettings"
    case logout            = "logoutSettings"
}

enum SettingsSections: Int, CaseIterable {
    
    case general           = 0
    case folders           = 1
    case security          = 2
    case mail              = 3
    case about             = 4
    case storage           = 5
    case logout            = 6
}

enum SettingsGeneralSection: Int, CaseIterable {
    
    case notification      = 0
    case language          = 1
    case contacts          = 2
    case whiteBlackList    = 3
}

enum SettingsFoldersSection: Int, CaseIterable {
    
    case folder            = 0
}

enum SettingsSecuritySection: Int, CaseIterable {
    
    case password          = 0
    case recovery          = 1
    case encryption        = 2
}

enum SettingsMailSection: Int, CaseIterable {
    
    case mail              = 0
    case signature         = 1
    case mobileSignature   = 2
}

enum SettingsAboutSection: Int, CaseIterable {
    
    //case aboutAs           = 0
    //case privacy           = 1
  //  case terms            = 2
//    case appVersion        = 3
    case appVersion        = 0
}

enum TextControllerMode: Int, CaseIterable {
    
    case privacyPolicy      = 0
    case termsAndConditions = 1
}

enum Languages: Int, CaseIterable {
    
    case english            = 0
    case russian            = 1
    case french             = 2
}

enum LanguagesName: String {
    
    case english            = "English"
    case russian            = "Русский"
    case french             = "Français"
}

enum LanguagesBundlePrefix: String {
    
    case english            = "en"
    case russian            = "ru"
    case french             = "fr"
}

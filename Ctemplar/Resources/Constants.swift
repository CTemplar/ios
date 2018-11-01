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
let k_MoveToViewControllerID                = "MoveToViewController"
let k_AboutAsViewControllerID               = "AboutAsViewController"

// view controllers storyboards name

let k_LoginStoryboardName                  = "Login"
let k_SignUpStoryboardName                 = "SignUp"
let k_ForgotPasswordStoryboardName         = "ForgotPassword"
let k_InboxStoryboardName                  = "Inbox"
let k_InboxSideMenuStoryboardName          = "InboxSideMenu"
let k_ComposeStoryboardName                = "Compose"
let k_AboutAsStoryboardName                = "AboutAs"
let k_MoveToStoryboardName                 = "MoveTo"
let k_ViewInboxEmailStoryboardName         = "ViewInboxEmail"

let k_InboxMessageTableViewCellXibName     = "InboxMessageTableViewCell"
let k_InboxFilterViewXibName               = "InboxFilter"
let k_SideMenuTableSectionHeaderViewXibName               = "SideMenuTableSectionHeader"
let k_SideMenuTableViewCellXibName         = "SideMenuTableViewCell"

// cell identifier

let k_InboxMessageTableViewCellIdentifier       = "inboxMessageTableViewCellIdentifier"
let k_SideMenuTableSectionHeaderViewIdentifier  = "sideMenuTableSectionHeaderViewIdentifier"
let k_SideMenuTableViewCellIdentifier           = "sideMenuTableViewCellIdentifier"

// view controllers iPad storyboards name

let k_LoginStoryboardName_iPad             = "Login-iPad"


// colors

let k_lightRedColor: UIColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 0.2)
let k_redColor: UIColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)

let k_sideMenuColor: UIColor = UIColor(red: 23.0/255.0, green: 50.0/255.0, blue: 77.0/255.0, alpha: 1.0)
let k_sideMenuSeparatorColor: UIColor = UIColor(red: 23.0/255.0, green: 50.0/255.0, blue: 77.0/255.0, alpha: 0.1)
let k_sideMenuFadeColor: UIColor = UIColor(red: 2.0/255.0, green: 13.0/255.0, blue: 25.0/255.0, alpha: 0.56)
let k_sideMenuTextFadeColor: UIColor = UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 0.4)

let k_urlColor: UIColor = UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
let k_lightGrayColor: UIColor = UIColor(white: 0.0, alpha: 0.54)

let k_lightGrayTextColor: UIColor = UIColor(red: 147.0 / 255.0, green: 145.0 / 255.0, blue: 145.0 / 255.0, alpha: 1.0)


let k_whiteColor: UIColor = UIColor(red: 250.0 / 255.0, green: 251.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)
let k_selectedFolderColor: UIColor = UIColor(red: 18.0 / 255.0, green: 45.0 / 255.0, blue: 71.0 / 255.0, alpha: 0.1)

let k_unreadMessageColor : UIColor = UIColor(red: 9.0 / 255.0, green: 31.0 / 255.0, blue: 53.0 / 255.0, alpha: 0.02)


//size constants

let k_pageControlBottomOffset           = 30.0
let k_pageControlDotSize                = 8.0

let k_signUpPageKeyboardOffsetSmall     = 32.0
let k_signUpPageKeyboardOffsetMedium    = 64.0
let k_signUpPageKeyboardOffsetBig       = 96.0
let k_signUpPageKeyboardOffsetLarge     = 160.0

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

let k_inboxFilterViewCenterY    : CGFloat = 430.0

//images

let k_checkBoxUncheckedImageName    = "roundDark"
let k_checkBoxSelectedImageName     = "checkedBoxDark"

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

let k_whiteGarbageImageName         = "whiteSpam"
let k_whiteSpamImageName            = "whiteTrash"
let k_witeUnreadImageName           = "whiteUnread"
let k_witeMoveToImageName           = "whiteMoveTo"

let k_starOnImageName               = "StarOn"
let k_starOffImageName              = "StarOff"
let k_secureOnImageName             = "SecureOn"
let k_secureOffImageName            = "SecureOff"

let k_foldersIconImageName          = "foldersIcon"
let k_labelsIconImageName           = "labelsIcon"

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

// fonts

let k_latoRegularFontName = "Lato-Regular"
let k_latoBoldFontName    = "Lato-Bold"

// notifications

let k_updateInboxMessagesNotificationID       = "updateInboxMessagesNotification"

// other

let k_numberOfRounds               = 29
let k_saltPrefix                   = "$2a$10$"

let k_keyringFileName              = "keyring.gpg"

let k_termsURL                     = "https://ctemplar.com/terms"

let k_firstCharsForHeader          = 50

let k_tokenHoursExpiration         = 2
let k_tokenMinutesExpiration       = 170

let k_sideMenuSectionHeaderHeight  : CGFloat = 49
let k_sideMenuSeparatorHeight      : CGFloat = 1

let k_undoActionBarShowingSecs     = 5.0

enum InboxSideMenuOptionsName: String {
    
    case inbox            = "Inbox"
    case draft            = "Draft"
    case sent             = "Sent"
    case outbox           = "Outbox"
    case starred          = "Starred"
    case archive          = "Archive"
    case spam             = "Spam"
    case trash            = "Trash"
    case allMails         = "All Mails"
    case contact          = "Contact"
    case settings         = "Settings"
    case help             = "Help"
    case logout           = "Logout"
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

enum InboxFilterViewButtonsTag: Int {
    
    case clearAllButton   = 205
    case cancelButton     = 206
    case applyButton      = 207
}

enum SideMenuSectionIndex: Int {
    
    case mainFolders      = 0
    case options          = 1
    case customFolders    = 2    
    case sectionsCount    = 3
}

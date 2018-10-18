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
let k_InboxSideMenuControllerID             = "InboxSideMenuController"
let k_ViewInboxEmailViewControllerID        = "ViewInboxEmailViewController"
let k_ComposeViewControllerID               = "ComposeViewController"
let k_AboutAsViewControllerID               = "AboutAsViewController"

// view controllers storyboards name

let k_LoginStoryboardName                  = "Login"
let k_SignUpStoryboardName                 = "SignUp"
let k_ForgotPasswordStoryboardName         = "ForgotPassword"
let k_InboxStoryboardName                  = "Inbox"
let k_InboxSideMenuStoryboardName          = "InboxSideMenu"
let k_ComposeStoryboardName                = "Compose"
let k_AboutAsStoryboardName                = "AboutAs"
let k_ViewInboxEmailStoryboardName         = "ViewInboxEmail"

// view controllers iPad storyboards name

let k_LoginStoryboardName_iPad             = "Login-iPad"


// colors

let k_lightRedColor: UIColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 0.2)
let k_redColor: UIColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)

let k_sideMenuColor: UIColor = UIColor(red: 23.0/255.0, green: 50.0/255.0, blue: 77.0/255.0, alpha: 1.0)
let k_sideMenuFadeColor: UIColor = UIColor(red: 2.0/255.0, green: 13.0/255.0, blue: 25.0/255.0, alpha: 0.56)

let k_urlColor: UIColor = UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
let k_lightGrayColor: UIColor = UIColor(white: 0.0, alpha: 0.54)

let k_whiteColor: UIColor = UIColor(red: 250.0 / 255.0, green: 251.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)

//size constants

let k_pageControlBottomOffset       = 30.0
let k_pageControlDotSize            = 8.0
let k_signUpPageNameKeyboardHeight  = 128.0
let k_triangleOffset                = 16.0 + 5.0 + 5.0
let k_navBarButtonSize              = 32.0

//images

let k_checkBoxUncheckedImageName    = "roundDark"
let k_checkBoxSelectedImageName     = "checkedBoxDark"

let k_composeImageName              = "ComposeButton"
let k_composeRedImageName           = "ComposeRedButton"

let k_darkBackArrowImageName        = "BackArrowDark"

let k_garbageImageName              = "GarbageButton"
let k_spamImageName                 = "SpamButton"
let k_moveImageName                 = "MoveBatton"
let k_moreImageName                 = "MoreButton"

// fonts

let k_latoRegularFontName = "Lato-Regular"

// other
let k_numberOfRounds               = 29

let k_keyringFileName              = "keyring.gpg"

let k_termsURL = "https://ctemplar.com/terms" 

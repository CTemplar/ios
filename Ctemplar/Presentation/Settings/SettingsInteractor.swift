//
//  SettingsInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import AlertHelperKit

class SettingsInteractor {
    
    var viewController  : SettingsViewController?
    var presenter       : SettingsPresenter?
    var apiService      : APIService?

    func logOut() {
        
        self.viewController?.navigationController?.popViewController(animated: true)
        self.viewController?.sideMenuViewController?.presenter?.interactor?.logOut()
    }
    
    func SettingsCellPressed(indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case SettingsSections.general.rawValue:
            self.SettingsGeneralCellPressed(index: row)
        case SettingsSections.folders.rawValue:
            self.SettingsFoldersCellPressed(index: row)
        case SettingsSections.security.rawValue:
            self.SettingsSecurityCellPressed(index: row)
        case SettingsSections.mail.rawValue:
            self.SettingsMailCellPressed(index: row)
        case SettingsSections.about.rawValue:
            self.SettingsAboutCellPressed(index: row)
        default:
            break
        }
    }
    
    func SettingsGeneralCellPressed(index: Int) {
        switch index {
        case SettingsGeneralSection.language.rawValue:
            viewController?.router?.showSelectLanguageViewController()
        case SettingsGeneralSection.notification.rawValue:
            UIApplication.openAppSettings()
        case SettingsGeneralSection.contacts.rawValue:
            viewController?.router?.showSavingContactsViewController()
        case SettingsGeneralSection.whiteBlackList.rawValue:
            viewController?.router?.showWhiteBlackListsViewController()
        case SettingsGeneralSection.dashboard.rawValue:
            viewController?.router?.showDashboard()
        default:
            break
        }
    }
    
    func SettingsFoldersCellPressed(index: Int) {
        
        switch index {
        case SettingsFoldersSection.folder.rawValue:
            self.viewController?.router?.showManageFoldersViewController()
            break
        default:
            break
        }
    }
    
    func SettingsSecurityCellPressed(index: Int) {
        switch index {
        case SettingsSecuritySection.recovery.rawValue:
            self.viewController?.router?.showRecoveryEmailViewController()
            break
        case SettingsSecuritySection.password.rawValue:
            self.viewController?.router?.showChangePasswordViewController()
            break
        case SettingsSecuritySection.encryption.rawValue:
            self.viewController?.router?.showSecurityViewController()
            break
        default:
            break
        }
    }
    
    func SettingsMailCellPressed(index: Int) {
        
        switch index {
        case SettingsMailSection.mail.rawValue:
            self.viewController?.router?.showSetMailboxViewController()
            break
        case SettingsMailSection.signature.rawValue:
            self.viewController?.router?.showSetSignatureViewController(with: .general)
            break
        case SettingsMailSection.mobileSignature.rawValue:
            self.viewController?.router?.showSetSignatureViewController(with: .mobile)
            break
        case SettingsMailSection.keys.rawValue:
            self.viewController?.router?.showPgpKeysViewController()
            break
        default:
            break
        }
    }
    
    func SettingsAboutCellPressed(index: Int) {
        
        switch index {/*
        case SettingsAboutSection.aboutAs.rawValue:
            self.viewController?.router?.showAboutAsViewController()
            break
        case SettingsAboutSection.privacy.rawValue:
            self.viewController?.router?.showPrivacyAndTermsViewController(mode: TextControllerMode.privacyPolicy)
            break
        case SettingsAboutSection.terms.rawValue:
            self.viewController?.router?.showPrivacyAndTermsViewController(mode: TextControllerMode.termsAndConditions)
            break*/
        case SettingsAboutSection.appVersion.rawValue:
         
            break
        default:
            break
        }
    }
    
    func getLanguageName() -> String {
        
        var currentLanguage : String = ""
        
        let language = Bundle.getLanguage()
        
        switch language {
        case LanguagesBundlePrefix.english.rawValue:
            currentLanguage = LanguagesName.english.rawValue
        case LanguagesBundlePrefix.russian.rawValue:
            currentLanguage = LanguagesName.russian.rawValue
        case LanguagesBundlePrefix.french.rawValue:
            currentLanguage = LanguagesName.french.rawValue
        case LanguagesBundlePrefix.slovak.rawValue:
            currentLanguage = LanguagesName.slovak.rawValue
        default:
            currentLanguage = LanguagesName.english.rawValue
        }
        
        return currentLanguage
    }
    
    func userMyself() {
        
        apiService?.userMyself() {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("userMyself value:", value)
                
                let userMyself = value as! UserMyself
                self.viewController?.user = userMyself
                
                self.viewController?.dataSource?.reloadData()
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_updateUserDataNotificationID), object: value)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "User Myself Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}

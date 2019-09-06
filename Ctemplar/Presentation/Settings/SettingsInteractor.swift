//
//  SettingsInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

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
            break
        case SettingsSections.folders.rawValue:
            self.SettingsFoldersCellPressed(index: row)
            break
        case SettingsSections.security.rawValue:
            self.viewController?.router?.showSecurityViewController()
            break
        case SettingsSections.mail.rawValue:
            self.SettingsMailCellPressed(index: row)
            break
        case SettingsSections.about.rawValue:
            self.SettingsAboutCellPressed(index: row)
            break
        default:
            break
        }
    }
    
    func SettingsGeneralCellPressed(index: Int) {
        
        switch index {
        case SettingsGeneralSection.recovery.rawValue:
            self.viewController?.router?.showRecoveryEmailViewController()
            break
        case SettingsGeneralSection.password.rawValue:
            self.viewController?.router?.showChangePasswordViewController()
            break
        case SettingsGeneralSection.language.rawValue:
            self.viewController?.router?.showSelectLanguageViewController()
            break
        case SettingsGeneralSection.notification.rawValue:
            UIApplication.openAppSettings()
            break
        case SettingsGeneralSection.contacts.rawValue:
            self.viewController?.router?.showSavingContactsViewController()
            break
        case SettingsGeneralSection.whiteBlackList.rawValue:
            self.viewController?.router?.showWhiteBlackListsViewController()
            break
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
    
    func SettingsMailCellPressed(index: Int) {
        
        switch index {
        case SettingsMailSection.mail.rawValue:
            self.viewController?.router?.showSetMailboxViewController()
            break
        case SettingsMailSection.signature.rawValue:
            self.viewController?.router?.showSetSignatureViewController() 
            break
        case SettingsMailSection.mobileSignature.rawValue:
            
            break
        default:
            break
        }
    }
    
    func SettingsAboutCellPressed(index: Int) {
        
        switch index {
        case SettingsAboutSection.aboutAs.rawValue:
            self.viewController?.router?.showAboutAsViewController()
            break
        case SettingsAboutSection.privacy.rawValue:
            self.viewController?.router?.showPrivacyAndTermsViewController(mode: TextControllerMode.privacyPolicy)
            break
        case SettingsAboutSection.terms.rawValue:
            self.viewController?.router?.showPrivacyAndTermsViewController(mode: TextControllerMode.termsAndConditions)
            break
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

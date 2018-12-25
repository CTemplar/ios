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

            break
        case SettingsGeneralSection.notification.rawValue:
            
            break
        case SettingsGeneralSection.contacts.rawValue:
            
            break
        case SettingsGeneralSection.whiteBlackList.rawValue:
            
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
 
            break
        case SettingsMailSection.signature.rawValue:
 
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

            break
        case SettingsAboutSection.terms.rawValue:

            break
        case SettingsAboutSection.appVersion.rawValue:
         
            break
        default:
            break
        }
    }
    
    func userMyself() {
        
        apiService?.userMyself() {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("userMyself value:", value)
                
                let userMyself = value as! UserMyself
                self.viewController?.user = userMyself
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_updateUserDataNotificationID), object: value)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "User Myself Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}

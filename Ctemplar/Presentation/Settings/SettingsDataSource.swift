//
//  SettingsDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility
import Networking

let k_storageSectionsRowsCount = 1
let k_logoutSectionsRowsCount = 0

class SettingsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var tableView               : UITableView!
    var parentViewController    : SettingsViewController!
    var formatterService        : FormatterService?
  
    func initWith(parent: SettingsViewController, tableView: UITableView) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView()
        
        registerTableViewCell()
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        self.tableView.register(UINib(nibName: k_SettingsBaseTableViewCellXibName, bundle: nil), forCellReuseIdentifier: k_SettingsBaseTableViewCellIdentifier)
        
        self.tableView.register(UINib(nibName: k_SettingsStorageTableViewCellXibName, bundle: nil), forCellReuseIdentifier: k_SettingsStorageTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return SettingsSectionsName.allCases.count
    }
    
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int) -> String? {
     
        switch section {
        case SettingsSections.general.rawValue:
            return SettingsSectionsName.general.rawValue.localized()
        case SettingsSections.folders.rawValue:
            return SettingsSectionsName.folders.rawValue.localized()
        case SettingsSections.security.rawValue:
            return SettingsSectionsName.security.rawValue.localized()
        case SettingsSections.mail.rawValue:
            return SettingsSectionsName.mail.rawValue.localized()
        case SettingsSections.about.rawValue:
            return SettingsSectionsName.about.rawValue.localized()
        case SettingsSections.storage.rawValue:
            return SettingsSectionsName.storage.rawValue.localized()
        case SettingsSections.logout.rawValue:
            return SettingsSectionsName.logout.rawValue.localized()
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        self.setupHeader(view: view, section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case SettingsSections.logout.rawValue:
            return k_logoutHeaderViewHeight
        default:
            return k_settingsHeaderViewHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SettingsSections.general.rawValue:
            return SettingsGeneralSection.allCases.count
        case SettingsSections.folders.rawValue:
            return SettingsFoldersSection.allCases.count
        case SettingsSections.security.rawValue:
            return SettingsSecuritySection.allCases.count
        case SettingsSections.mail.rawValue:
            return SettingsMailSection.allCases.count
        case SettingsSections.about.rawValue:
            return SettingsAboutSection.allCases.count
        case SettingsSections.storage.rawValue:
            return k_storageSectionsRowsCount
        case SettingsSections.logout.rawValue:
            return k_logoutSectionsRowsCount
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settings = self.parentViewController?.user.settings
        let index = indexPath.row
        
        guard var cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: k_SettingsBaseTableViewCellIdentifier) as? SettingsBaseTableViewCell else {
            return UITableViewCell()
        }
        
        switch indexPath.section {
        case SettingsSections.general.rawValue:
            setupGeneralSectionsCell(index: index, cell: cell, settings: settings!)
        case SettingsSections.folders.rawValue:
            setupFoldersSectionCell(index: index, cell: cell)
        case SettingsSections.security.rawValue:
            setupSecuritySectionsCell(index: index, cell: cell, settings: settings!)
        case SettingsSections.mail.rawValue:
            setupMailSectionCell(index: index, cell: cell)
        case SettingsSections.about.rawValue:
            if index == SettingsAboutSection.appVersion.rawValue {
                cell = tableView.dequeueReusableCell(withIdentifier: k_SettingsAppVersionTableViewCellIdentifier)!
            }
            setupAboutSectionCell(index: index, cell: cell)
        case SettingsSections.storage.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: k_SettingsStorageTableViewCellIdentifier)!
            setupStorageSectionCell(cell: cell, settings: settings!)
        case SettingsSections.logout.rawValue:
            break
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case SettingsSections.storage.rawValue:
            return k_settingsStorageCellHeight
        default:
            return k_settingsBaseCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        parentViewController.presenter?.interactor?.SettingsCellPressed(indexPath: indexPath)        
    }
    
    @objc func reloadData() {
        
        self.tableView.reloadData()
    }
    
    //MARK: - setup Headers and Cells
    
    func setupHeader(view: UIView, section: Int) {
        let header = view as! UITableViewHeaderFooterView
        
        switch section {
        case SettingsSections.logout.rawValue:
            header.textLabel?.textAlignment = NSTextAlignment.center
            header.textLabel?.font = UIFont(name: k_latoRegularFontName, size: 18)!
            header.textLabel?.textColor = k_redColor
            
            let headerTapGesture = UITapGestureRecognizer()
            headerTapGesture.addTarget(self, action: #selector(self.tappedHeaderAction(sender:)))
            header.addGestureRecognizer(headerTapGesture)
        default:
            header.textLabel?.textAlignment = NSTextAlignment.left
            header.textLabel?.font = UIFont(name: k_latoRegularFontName, size: 15)!
            header.textLabel?.textColor = k_sideMenuTextFadeColor
        }
        
        for index in SettingsSections.allCases {            
            if let subview = header.viewWithTag(index.rawValue + 100) {
                subview.removeFromSuperview()
            }
        }
        
        let tag = 100 + section
        
        var frame = CGRect(x: 0, y: 0, width: header.frame.width, height: 1.0)
        let upperlineView = UIView(frame: frame)
        upperlineView.backgroundColor = k_settingHeaderLineColor
        header.add(subview: upperlineView)
        
        frame = CGRect(x: 0, y: header.bounds.height - 1.0, width: header.frame.width, height: 1.0)
        let bottomlineView = UIView(frame: frame)
        bottomlineView.tag = tag
        bottomlineView.backgroundColor = k_settingHeaderLineColor
        header.add(subview: bottomlineView)
        
        let bkgView = UIView()
        bkgView.backgroundColor = k_settingsHeaderBackgroundColor //UIColor(white: 247/255.0, alpha: 1.0)
        header.backgroundView = bkgView
    }
    
    func setupGeneralSectionsCell(index: Int, cell: UITableViewCell, settings: Settings) {
        var cellTitle = ""
        var value = ""
        
        switch index {
        case SettingsGeneralSection.language.rawValue:
            cellTitle = "language".localized()
            value = (self.parentViewController?.presenter?.interactor?.getLanguageName())!
        case SettingsGeneralSection.notification.rawValue:
            cellTitle = "notifications".localized()
        case SettingsGeneralSection.contacts.rawValue:
            cellTitle = "savingContact".localized()
        case SettingsGeneralSection.whiteBlackList.rawValue:
            cellTitle = "whiteBlackList".localized()
        case SettingsGeneralSection.dashboard.rawValue:
            cellTitle = "dashboard".localized()
        default:
            break
        }
        (cell as? SettingsBaseTableViewCell)?.setupCellWithData(title: cellTitle, value: value)
    }
    
    func setupFoldersSectionCell(index: Int, cell: UITableViewCell) {
        var cellTitle = ""
        
        switch index {
        case SettingsFoldersSection.folder.rawValue:
            cellTitle = "manageFolders".localized()
        default:
            break
        }
        
        (cell as? SettingsBaseTableViewCell)?.setupCellWithData(title: cellTitle, value: "")
    }
    
    func setupSecuritySectionsCell(index: Int, cell: UITableViewCell, settings: Settings) {
        var cellTitle : String = ""
        switch index {
        case SettingsSecuritySection.password.rawValue:
            cellTitle = "password".localized()
        case SettingsSecuritySection.recovery.rawValue:
            cellTitle = "recoveryEmail".localized()
        case SettingsSecuritySection.encryption.rawValue:
            cellTitle = "manageSecurity".localized()
        default:
            break
        }
        
        (cell as! SettingsBaseTableViewCell).setupCellWithData(title: cellTitle, value: "")
    }
    
    func setupMailSectionCell(index: Int, cell: UITableViewCell) {
        var cellTitle = ""
        var value = ""
        
        guard let mailboxes = parentViewController?.user.mailboxesList,
            let mailbox = parentViewController.presenter?.interactor?.apiService?.defaultMailbox(mailboxes: mailboxes) else {
            return
        }
        
        switch index {
        case SettingsMailSection.mail.rawValue:
            if let email = mailbox.email {
                cellTitle = email
            }
            
            if mailbox.isDefault! {
                value = "default".localized()
            }
            break
        case SettingsMailSection.signature.rawValue:
            cellTitle = "signature".localized()
        case SettingsMailSection.mobileSignature.rawValue:
            if let signature = UserDefaults.standard.string(forKey: k_mobileSignatureKey) {
                if signature.count > 0 {
                    cellTitle = signature
                } else {
                    cellTitle = "mobileSignature".localized()
                }
            } else {
                cellTitle = "mobileSignature".localized()
            }
        case SettingsMailSection.keys.rawValue:
            cellTitle = "keys".localized()
            value = ""
        default:
            break
        }
        
        (cell as? SettingsBaseTableViewCell)?.setupCellWithData(title: cellTitle, value: value)
    }
    
    func setupAboutSectionCell(index: Int, cell: UITableViewCell) {
        switch index {
        case SettingsAboutSection.appVersion.rawValue:
            self.setupAppVersionCell(cell: cell)
        default:
            break
        }
    }
    
    func setupAppVersionCell(cell: UITableViewCell) {
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        
        cell.textLabel?.font = UIFont(name: k_latoRegularFontName, size: 16)!
        cell.textLabel?.textColor = k_sideMenuTextFadeColor
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = "appVersion".localized() + appVersion + " (" + buildNumber + ")"
        cell.selectionStyle = .none
    }
    
    func setupStorageSectionCell(cell: UITableViewCell, settings: Settings) {
        var usedStorageSpace = 0
        var totalStorageSpace = 0
        
        if let usedSpace = settings.usedStorage {
            usedStorageSpace = usedSpace
        }
        
        if let totalSpace = settings.allocatedStorage {
            totalStorageSpace = totalSpace
        }
        
        (cell as? SettingsStorageTableViewCell)?.setupCellWithData(usedStorageSpace: usedStorageSpace, totalStorageSpace: totalStorageSpace)
    }
    
    @objc
    func tappedHeaderAction(sender : UITapGestureRecognizer) {
        print("tap to Logout")
        self.parentViewController?.presenter?.logOut()
    }
}

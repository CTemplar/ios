//
//  SettingsDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


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
            return 1
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
        
        var cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: k_SettingsBaseTableViewCellIdentifier) as! SettingsBaseTableViewCell
        
        switch indexPath.section {
        case SettingsSections.general.rawValue:
            self.setupGeneralSectionsCell(index: index, cell: cell, settings: settings!)
            break
        case SettingsSections.folders.rawValue:
            self.setupFoldersSectionCell(index: index, cell: cell)
            break
        case SettingsSections.security.rawValue:
            self.setupSecuritySectionsCell(index: index, cell: cell, settings: settings!)
            break
        case SettingsSections.mail.rawValue:
            self.setupMailSectionCell(index: index, cell: cell)
            break
        case SettingsSections.about.rawValue:
            if index == SettingsAboutSection.appVersion.rawValue {
                cell = tableView.dequeueReusableCell(withIdentifier: k_SettingsAppVersionTableViewCellIdentifier)!
            }
            self.setupAboutSectionCell(index: index, cell: cell)
            break
        case SettingsSections.storage.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: k_SettingsStorageTableViewCellIdentifier)!
            self.setupStorageSectionCell(cell: cell, settings: settings!)
            break
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
        
        self.parentViewController.presenter?.interactor?.SettingsCellPressed(indexPath: indexPath)        
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
            
            break
        default:
            header.textLabel?.textAlignment = NSTextAlignment.left
            header.textLabel?.font = UIFont(name: k_latoRegularFontName, size: 14)!
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
    }
    
    func setupGeneralSectionsCell(index: Int, cell: UITableViewCell, settings: Settings) {
        
        var cellTitle : String = ""
        var value : String = ""
        
        switch index {
        case SettingsGeneralSection.recovery.rawValue:
            cellTitle = "recoveryEmail".localized()
            break
        case SettingsGeneralSection.password.rawValue:
            cellTitle = "password".localized()
            break
        case SettingsGeneralSection.language.rawValue:
            cellTitle = "language".localized()
            //if let language = settings.language {
            //    value = language
            //}
            value = (self.parentViewController?.presenter?.interactor?.getLanguageName())!
            
            break
        case SettingsGeneralSection.notification.rawValue:
            cellTitle = "notifications".localized()
            break
        case SettingsGeneralSection.contacts.rawValue:
            cellTitle = "savingContact".localized()
            break
        case SettingsGeneralSection.whiteBlackList.rawValue:
            cellTitle = "whiteBlackList".localized()
            break
        default:
            break
        }
        
        (cell as! SettingsBaseTableViewCell).setupCellWithData(title: cellTitle, value: value)
    }
    
    func setupFoldersSectionCell(index: Int, cell: UITableViewCell) {
        
        var cellTitle : String = ""
        
        switch index {
        case SettingsFoldersSection.folder.rawValue:
            cellTitle = "manageFolders".localized()
            break
        default:
            break
        }
        
        (cell as! SettingsBaseTableViewCell).setupCellWithData(title: cellTitle, value: "")
    }
    
    func setupSecuritySectionsCell(index: Int, cell: UITableViewCell, settings: Settings) {
        
        var cellTitle : String = ""
        
        cellTitle = "manageSecurity".localized()
        
        (cell as! SettingsBaseTableViewCell).setupCellWithData(title: cellTitle, value: "")
    }
    
    func setupMailSectionCell(index: Int, cell: UITableViewCell) {
        
        var cellTitle : String = ""
        var value : String = ""
        
        let mailbox = self.parentViewController.presenter!.interactor!.apiService!.defaultMailbox(mailboxes: self.parentViewController!.user.mailboxesList!)
        
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
//            if let signature = mailbox.signature {
//                if signature.count > 0 {
//                    cellTitle = signature.removeHTMLTag
//                    (cell as! SettingsBaseTableViewCell).titleLabel.numberOfLines = 0
////                    let attributedText = signature.html2AttributedString ?? NSAttributedString()
////                    (cell as! SettingsBaseTableViewCell).setupCellWithData(attributedTitle: attributedText, value: "")
////                    return
//                } else {
//                    cellTitle = "signature".localized()
//                }
//            } else {
//                cellTitle = "signature".localized()
//            }
            break
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
        default:
            break
        }
        
        (cell as! SettingsBaseTableViewCell).setupCellWithData(title: cellTitle, value: value)
    }
    
    func setupAboutSectionCell(index: Int, cell: UITableViewCell) {
        
        var cellTitle : String = ""
        
        switch index {/*
        case SettingsAboutSection.aboutAs.rawValue:
            cellTitle = "aboutUs".localized()
            (cell as! SettingsBaseTableViewCell).setupCellWithData(title: cellTitle, value: "")
            break
        case SettingsAboutSection.privacy.rawValue:
            cellTitle = "privacyPolicy".localized()
            (cell as! SettingsBaseTableViewCell).setupCellWithData(title: cellTitle, value: "")
            break
        case SettingsAboutSection.terms.rawValue:
            cellTitle = "terms".localized()
            (cell as! SettingsBaseTableViewCell).setupCellWithData(title: cellTitle, value: "")
            break */
        case SettingsAboutSection.appVersion.rawValue:
            self.setupAppVersionCell(cell: cell)
            break
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
        
        (cell as! SettingsStorageTableViewCell).setupCellWithData(usedStorageSpace: usedStorageSpace, totalStorageSpace: totalStorageSpace)
    }
    
    @objc func tappedHeaderAction(sender : UITapGestureRecognizer) {
        
        print("tap to Logout")
        self.parentViewController?.presenter?.logOut()
    }
}

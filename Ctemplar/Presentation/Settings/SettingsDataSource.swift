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
    
    var generalSettingsArray           : Array<Any> = []
    
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
            return SettingsSectionsName.general.rawValue
        case SettingsSections.folders.rawValue:
            return SettingsSectionsName.folders.rawValue
        case SettingsSections.mail.rawValue:
            return SettingsSectionsName.mail.rawValue
        case SettingsSections.about.rawValue:
            return SettingsSectionsName.about.rawValue
        case SettingsSections.storage.rawValue:
            return SettingsSectionsName.storage.rawValue
        case SettingsSections.logout.rawValue:
            return SettingsSectionsName.logout.rawValue
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
            return self.generalSettingsArray.count
        case SettingsSections.folders.rawValue:
            return 1
        case SettingsSections.mail.rawValue:
            return 1
        case SettingsSections.about.rawValue:
            return 1
        case SettingsSections.storage.rawValue:
            return k_storageSectionsRowsCount
        case SettingsSections.logout.rawValue:
            return k_logoutSectionsRowsCount
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: k_SettingsBaseTableViewCellIdentifier) as! SettingsBaseTableViewCell
        
        switch indexPath.section {
        case SettingsSections.general.rawValue:
            break
        case SettingsSections.folders.rawValue:
            break
        case SettingsSections.mail.rawValue:
            break
        case SettingsSections.about.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: k_SettingsAppVersionTableViewCellIdentifier)!
            self.setupAppVersionCell(cell: cell)
            break
        case SettingsSections.storage.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: k_SettingsStorageTableViewCellIdentifier)!
            (cell as! SettingsStorageTableViewCell).setupCellWithData(usedStorageSpace: 14172, totalStorageSpace: 204800)
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
        
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
    }
    
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
        
        var frame = CGRect(x: 0, y: 0, width: header.frame.width, height: 1.0)
        let upperlineView = UIView(frame: frame)
        upperlineView.backgroundColor = k_settingHeaderLineColor
        header.add(subview: upperlineView)
        
        frame = CGRect(x: 0, y: header.frame.height - 1.0, width: header.frame.width, height: 1.0)
        let bottomlineView = UIView(frame: frame)
        bottomlineView.backgroundColor = k_settingHeaderLineColor
        header.add(subview: bottomlineView)
    }
    
    func setupAppVersionCell(cell: UITableViewCell) {
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        
        cell.textLabel?.font = UIFont(name: k_latoRegularFontName, size: 16)!
        cell.textLabel?.textColor = k_sideMenuTextFadeColor
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = "AppVersion " + appVersion + " (" + buildNumber + ")"
    }
    
    @objc func tappedHeaderAction(sender : UITapGestureRecognizer) {
        
        print("tap to Logout")
        self.parentViewController?.presenter?.logOut()
    }
}

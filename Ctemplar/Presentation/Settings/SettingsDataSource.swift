//
//  SettingsDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class SettingsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var settingsArray           : Array<Any> = []
    
    var tableView               : UITableView!
    var parentViewController    : SettingsViewController!
    var formatterService        : FormatterService?
  
    func initWith(parent: SettingsViewController, tableView: UITableView) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        registerTableViewCell()
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        //self.tableView.register(UINib(nibName: k_ContactCellXibName, bundle: nil), forCellReuseIdentifier: k_ContactTableViewCellIdentifier)
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
    
    //func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
    //}
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: k_latoRegularFontName, size: 14)!
        header.textLabel?.textColor = k_sideMenuTextFadeColor
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
        
        return 1//settingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "settingsCellIdentifier")!
        
        cell.textLabel?.text = "1"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
    }
}

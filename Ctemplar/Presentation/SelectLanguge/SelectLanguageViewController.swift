//
//  SelectLanguageViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 28.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import AlertHelperKit
import PKHUD

class SelectLanguageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet var tableView               : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarTitle()
        
        self.registerTableViewCell()
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        self.tableView.register(UINib(nibName: k_UserMailboxBigCellXibName, bundle: nil), forCellReuseIdentifier: k_UserMailboxBigTableViewCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Languages.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: k_UserMailboxBigTableViewCellIdentifier)! as! UserMailboxBigTableViewCell
        
        var languageName : String = ""
        
        switch indexPath.row {
        case Languages.english.rawValue:
            languageName = LanguagesName.english.rawValue
            break
        case Languages.russian.rawValue:
            languageName = LanguagesName.russian.rawValue
            break
        case Languages.french.rawValue:
            languageName = LanguagesName.french.rawValue
        default:
            break
        }
        
        let selected = self.isLanguageSelected(index: indexPath.row)
        
        cell.setupCellWithData(email: languageName, seleted: selected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var languagePrefix : LanguagesBundlePrefix!
        
        switch indexPath.row {
        case Languages.english.rawValue:
            languagePrefix = LanguagesBundlePrefix.english
            break
        case Languages.russian.rawValue:
            languagePrefix = LanguagesBundlePrefix.russian
            break
        case Languages.french.rawValue:
            languagePrefix = LanguagesBundlePrefix.french
        default:
            languagePrefix = LanguagesBundlePrefix.english
            break
        }
        
        self.selectLangage(language: languagePrefix)
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
    }
    
    func selectLangage(language: LanguagesBundlePrefix) {
    
        Bundle.setLanguage(lang: language.rawValue)
        
        self.reloadViewController()
    }
    
    func setNavigationBarTitle() {
  
        self.navigationItem.title = "languageTitle".localized()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: k_navBar_titleColor]
    }
    
    func reloadViewController() {
        
        self.viewDidLoad()
        self.viewWillAppear(true)
        self.reloadData()
        
        NotificationCenter.default.post(name: Notification.Name(k_reloadViewControllerNotificationID), object: nil, userInfo: nil)
    }
    
    func isLanguageSelected(index: Int) -> Bool {
        
        var language : String = ""
        let currentLanguage = Bundle.getLanguage()
        
        switch index {
        case Languages.english.rawValue:
            language = LanguagesBundlePrefix.english.rawValue
        case Languages.russian.rawValue:
            language = LanguagesBundlePrefix.russian.rawValue
        case Languages.french.rawValue:
            language = LanguagesBundlePrefix.french.rawValue
        default:
            language = LanguagesBundlePrefix.english.rawValue
        }
        
        if language == currentLanguage {
            return true
        }
        
        return false
    }
}

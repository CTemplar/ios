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
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: k_passwordBarTintColor]
        
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
        default:
            break
        }
        
        var selected = false
        
        cell.setupCellWithData(email: languageName, seleted: selected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    func reloadData() {
        
        self.tableView.reloadData()
    }
}

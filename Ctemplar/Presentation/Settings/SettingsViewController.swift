//
//  SettingsViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class  SettingsViewController: UIViewController {
    
    var presenter   : SettingsPresenter?
    var router      : SettingsRouter?
    var dataSource  : SettingsDataSource?
    
    @IBOutlet var leftBarButtonItem        : UIBarButtonItem!
    
    @IBOutlet var settingsTableView        : UITableView!
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let configurator =  SettingsConfigurator()
        configurator.configure(viewController: self)
        
        //dataSource?.initWith(parent: self, tableView: settingsTableView)
    }
    
    //MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        
        self.router?.showInboxSideMenu()  
    }
}

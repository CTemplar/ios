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
    
    var sideMenuViewController : InboxSideMenuViewController?
    
    @IBOutlet var leftBarButtonItem        : UIBarButtonItem!
    
    @IBOutlet var settingsTableView        : UITableView!
    
    var user = UserMyself()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let configurator =  SettingsConfigurator()
        configurator.configure(viewController: self)
        
        dataSource?.initWith(parent: self, tableView: settingsTableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userSettingsUpdate), name: NSNotification.Name(rawValue: k_updateUserSettingsNotificationID), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadViewController), name: NSNotification.Name(rawValue: k_reloadViewControllerNotificationID), object: nil)
    }
    
    @objc func reloadViewController() {
        
        self.viewDidLoad()
        self.viewWillAppear(false)
    }
    
    //MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        
        self.router?.showInboxSideMenu()  
    }
    
    @objc func userSettingsUpdate(notification: Notification) {
        
        self.presenter?.interactor?.userMyself()
    }
}

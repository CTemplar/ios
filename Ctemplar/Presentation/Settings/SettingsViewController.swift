//
//  SettingsViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Networking

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
        
        self.navigationItem.title = "settings".localized()
        
        dataSource?.initWith(parent: self, tableView: settingsTableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userSettingsUpdate), name: .updateUserSettingsNotificationID, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadViewController), name: .reloadViewControllerNotificationID, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataSource), name: .reloadViewControllerDataSourceNotificationID, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.setupNavigationLeftItem()
    }
    
    @objc func reloadViewController() {
        
        self.viewDidLoad()
        self.viewWillAppear(false)
    }
    
    @objc func updateDataSource() {
        dataSource?.reloadData()
    }
    
    //MARK: - IBActions

    @objc func userSettingsUpdate(notification: Notification) {
        
        self.presenter?.interactor?.userMyself()
    }
    
    //MARK: - Orientation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if (Device.IS_IPAD) {
            self.presenter?.setupNavigationLeftItem()
        }
    }
}

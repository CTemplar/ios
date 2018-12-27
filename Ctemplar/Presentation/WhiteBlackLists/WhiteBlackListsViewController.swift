//
//  WhiteBlackListsViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

enum WhiteBlackListsMode: Int {
    
    case whiteList   = 0
    case blackList   = 1
}

class WhiteBlackListsViewController: UIViewController {
    
    @IBOutlet var tableView             : UITableView!
    
    @IBOutlet var segmentedControl      : UISegmentedControl!
    @IBOutlet var underlineView         : UIView!
    
    @IBOutlet var addContactButton      : UIButton!
    @IBOutlet var textLabel             : UILabel!
    
    @IBOutlet var underlineWidthConstraint              : NSLayoutConstraint!
    @IBOutlet var underlineLeftOffsetConstraint         : NSLayoutConstraint!
    
    var user = UserMyself()
    
    var listMode = WhiteBlackListsMode.whiteList
    
    var presenter   : WhiteBlackListsPresenter?
    var router      : WhiteBlackListsRouter?
    var dataSource  : WhiteBlackListsDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator =  WhiteBlackListsConfigurator()
        configurator.configure(viewController: self)
        
        self.dataSource?.initWith(parent: self, tableView: tableView)
        
        self.presenter?.setupSegmentedControl()
        self.segmentedControl.sendActions(for: UIControl.Event.valueChanged)        
        self.presenter?.setupTableAndDataSource(user: self.user, listMode: self.listMode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController!.navigationBar.hideBorderLine()
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addContactButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        self.presenter?.segmentedControlValueChanged(sender)
    }
}

//
//  MoveToViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 31.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class MoveToViewController: UIViewController {
    
    var presenter   : MoveToPresenter?
    var router      : MoveToRouter?
    var dataSource  : MoveToDataSource?
    
    @IBOutlet var cancelButton          : UIButton!
    @IBOutlet var applyButton           : UIButton!
    
    @IBOutlet var moveToTableView       : UITableView!

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = MoveToConfigurator()
        configurator.configure(viewController: self)
        
        dataSource?.initWith(parent: self, tableView: moveToTableView)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.presenter?.interactor?.customFoldersList()
    }
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func manageFoldersButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func applyButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

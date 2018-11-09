//
//  SearchViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit
import Foundation
import PKHUD
import AlertHelperKit

class SearchViewController: UIViewController {
    
    var presenter   : SearchPresenter?
    var router      : SearchRouter?
    var dataSource  : SearchDataSource?
    
    var messagesList    : Array<EmailMessage> = []
    
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    @IBOutlet var searchTableView        : UITableView!    
    @IBOutlet var emptySearch            : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = SearchConfigurator()
        configurator.configure(viewController: self)
        
        presenter?.setupNavigationBarItem(searchBar: searchBar)
        
        dataSource?.initWith(parent: self, tableView: searchTableView, array: messagesList)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.presenter?.interactor?.allMessagesList()     
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        
    }
}

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
    
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    @IBOutlet var searchTableView        : UITableView!
    
    @IBOutlet var emptySearch            : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar.placeholder = "Search"
        searchBar.sizeToFit()
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).leftViewMode = .never
        
        if let txfSearchField = searchBar.value(forKey: "_searchField") as? UITextField {
            txfSearchField.borderStyle = .none
            txfSearchField.backgroundColor = self.navigationItem.titleView?.backgroundColor
        }
        
        navigationItem.titleView = searchBar       
        

    
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        
        
    }
}

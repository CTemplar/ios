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

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var presenter   : SearchPresenter?
    var router      : SearchRouter?
    var dataSource  : SearchDataSource?
    
    var messagesList    : Array<EmailMessage> = []
    var filteredArray   : Array<EmailMessage> = []
    
    var senderEmail: String = ""
    //var mailboxesList    : Array<Mailbox> = []
    var user = UserMyself()
    
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    var searchActive : Bool = false
    
    @IBOutlet var searchTableView        : UITableView!    
    @IBOutlet var emptySearch            : UIView!
    
    @IBOutlet var bottomTableViewOffsetConstraint: NSLayoutConstraint!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = SearchConfigurator()
        configurator.configure(viewController: self)
        
        presenter?.setupNavigationBarItem(searchBar: searchBar)
        
        dataSource?.initWith(parent: self, tableView: searchTableView, array: messagesList)
        
        searchBar.delegate = self
        addNotificationObserver()
        
        self.presenter?.updateMessges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //presenter?.setupNavigationBarItem(searchBar: searchBar)
        //self.dataSource?.reloadData()
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        
    }
    
    // MARK: SearchBar delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBarIsEmpty() -> Bool {
        
        return searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        
        return searchActive && !searchBarIsEmpty()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.presenter?.interactor?.setFilteredList(searchText: searchText)
    }
    
    //MARK: - notification
    
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            bottomTableViewOffsetConstraint.constant = -keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        bottomTableViewOffsetConstraint.constant = 0.0
    }
}

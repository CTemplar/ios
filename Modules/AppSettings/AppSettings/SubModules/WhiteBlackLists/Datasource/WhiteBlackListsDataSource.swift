import Foundation
import UIKit
import Utility
import Networking

final class WhiteBlackListsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    // MARK: Properties
    private weak var tableView: UITableView?
    
    private weak var parentViewController: WhiteBlackListsViewController?
    
    private let formatterService = UtilityManager.shared.formatterService
    
    private (set) var contacts: [Contact] = []
    
    private (set) var filteredContacts: [Contact] = []
    
    private (set) var searchText = ""
    private (set) var filtered = false
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        return refreshControl
    }()
    
    // MARK: - Constructor
    init(parent: WhiteBlackListsViewController, tableView: UITableView) {
        self.parentViewController = parent
        self.tableView = tableView
        super.init()
        setupTableView()
    }
    
    // MARK: - Setup
    func setupTableView() {
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        
        self.tableView?.addSubview(self.refreshControl)
        self.tableView?.tableFooterView = UIView()
        tableView?.register(UINib(nibName: ContactTableViewCell.className,
                                  bundle: Bundle(for: ContactTableViewCell.self)),
                           forCellReuseIdentifier: ContactTableViewCell.className)
    }
    
    // MARK: - Update Datasource
    func update(filteredContacts: [Contact]) {
        self.filteredContacts = filteredContacts
    }
    
    func update(contacts: [Contact]) {
        self.contacts = contacts
    }
    
    func update(searchText: String) {
        self.searchText = searchText
    }
    
    func update(filtered: Bool) {
        self.filtered = filtered
    }
    
    func reloadData() {
        refreshControl.endRefreshing()
        tableView?.reloadData()
    }
    
    // MARK: - Actions
    @objc
    private func handleRefresh(_ refreshControl: UIRefreshControl) {
        parentViewController?.presenter?.interactor?.getWhiteListContacts(silent: true)
        parentViewController?.presenter?.interactor?.getBlackListContacts(silent: true)
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered ? filteredContacts.count : contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.className) as? ContactTableViewCell else {
            return UITableViewCell()
        }
        
        let contact = filtered ? filteredContacts[indexPath.row] : contacts[indexPath.row]
        
        cell.setupCellWithData(contact: contact, isSelectionMode: false, isSelected: false, foundText: searchText)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let contact = contacts[indexPath.row]
            if let contactID = contact.contactID?.description,
                let listMode = parentViewController?.listMode {
                parentViewController?.presenter?.deleteContactFromList(contactID: contactID,
                                                                       listMode: listMode)
            }
        }
    }
}

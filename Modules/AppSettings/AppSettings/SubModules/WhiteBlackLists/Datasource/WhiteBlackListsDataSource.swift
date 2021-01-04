import Foundation
import UIKit
import Utility
import Networking
import SwipeCellKit

final class WhiteBlackListsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    // MARK: Properties
    private weak var tableView: UITableView?
    
    private weak var parentViewController: WhiteBlackListsViewController?
    
    private let formatterService = UtilityManager.shared.formatterService
    
    private (set) var contacts: [Contact] = []
    
    private (set) var filteredContacts: [Contact] = []
    
    private (set) var searchText = ""
    
    private (set) var filtered = false
    
    private lazy var defaultOptions: SwipeOptions = {
        return SwipeOptions()
    }()
    
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
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        tableView?.addSubview(self.refreshControl)
        tableView?.tableFooterView = UIView()
        tableView?.backgroundColor = .systemGroupedBackground
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
        cell.configure(with: contact, foundText: searchText)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
}

// MARK: - SwipeTableViewCellDelegate
extension WhiteBlackListsDataSource: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        switch orientation {
        case .left:
            return nil
        case .right:
            return rightSwipeAction(for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        options.transitionStyle = defaultOptions.transitionStyle
        options.buttonSpacing = 4
        options.backgroundColor = .clear
        return options
    }
}

// MARK: - Swipe Actions
private extension WhiteBlackListsDataSource {
    func rightSwipeAction(for indexPath: IndexPath) -> [SwipeAction]? {
        guard contacts.count > indexPath.row else {
            return nil
        }

        let contact = contacts[indexPath.row]

        let trashAction = SwipeAction(style: .default, title: nil) { [weak self] (action, indexPath) in
            if let contactID = contact.contactID?.description,
               let listMode = self?.parentViewController?.listMode {
                self?.parentViewController?
                    .presenter?
                    .deleteContactFromList(contactID: contactID,
                                           listMode: listMode)
            }
        }
        
        trashAction.hidesWhenSelected = true
        configure(action: trashAction, with: .trash)
        
        return [trashAction]
    }
    
    private func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: .titleAndImage)
        action.image = descriptor.image(forStyle: .circular, displayMode: .titleAndImage)
        action.backgroundColor = .clear
        action.textColor = descriptor.color(forStyle: .circular)
        action.font = .withType(.ExtraSmall(.Bold))
        action.transitionDelegate = ScaleTransition.default
    }
}

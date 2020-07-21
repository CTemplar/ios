import Foundation
import Networking
import Utility
import UIKit

final class GlobalSearchDataSource: NSObject {
    // MARK: Properties
    private weak var tableView: UITableView?
    private (set) var messages: [EmailMessage] = []
    private (set) var folders: [Folder] = []
    private var user = UserMyself()
    private weak var presenter: GlobalSearchPresenter?
    
    // MARK: - Constructor
    init(tableView: UITableView, presenter: GlobalSearchPresenter?) {
        self.tableView = tableView
        self.presenter = presenter
        super.init()
        
        self.tableView?.keyboardDismissMode = .interactive
        self.tableView?.contentInsetAdjustmentBehavior = .never
        self.tableView?.tableFooterView = UIView()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.register(UINib(nibName: SearchTableViewCell.className,
                                      bundle: Bundle(for: SearchTableViewCell.self)),
                                forCellReuseIdentifier: SearchTableViewCell.className)
    }
    
    // MARK: - Update
    func updateDatasource(by messages: [EmailMessage]) {
        self.messages = messages
        tableView?.reloadSections(IndexSet(integer: 0), with: .automatic)
        
        if messages.isEmpty {
            tableView?.tableFooterView = UIView()
        }
        
        presenter?.turnOffLoading()
        presenter?.updateEmptyState(shouldShow: messages.isEmpty)
    }
    
    func updateMessageStatus(message: EmailMessage, status: Bool) {
        if let index = messages.firstIndex(where: { $0.messsageID == message.messsageID }) {
            var message = messages[index]
            message.update(readStatus: status)
            messages[index] = message
            tableView?.reloadData()
        }
    }
    
    func update(folders: [Folder]) {
        self.folders = folders
    }

    func update(user: UserMyself?) {
        if let user = user {
            self.user = user
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension GlobalSearchDataSource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        let totalItems = presenter?.interactor.totalItems ?? 0
        
        if indexPath.section == lastSectionIndex,
            indexPath.row == lastRowIndex,
            messages.count < totalItems {
                        
            presenter?.searchController.searchBar.isLoading = true
            presenter?.interactor.searchMessages(withQuery: presenter?.searchQuery ?? "")
            
            if presenter?.interactor.isFetchInProgress == true {
                let spinner = MatericalIndicator.shared.loader(with: CGSize(width: 50.0, height: 50.0))
                tableView.tableFooterView = spinner
                spinner.startAnimating()
            } else {
                tableView.tableFooterView = UIView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.className,
                                                       for: indexPath) as? SearchTableViewCell else {
            return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        
        cell.setupCellWithData(withFolders: folders, message: message, foundText: presenter?.searchQuery ?? "")
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero

        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let message = messages[indexPath.row]
        
        // Dismiss the search controller first
        self.presenter?.searchController.dismiss(animated: true, completion: { [weak self] in
            guard let safeSelf = self else { return }
            safeSelf.presenter?.onTap(message: message, user: safeSelf.user)
        })
    }
}

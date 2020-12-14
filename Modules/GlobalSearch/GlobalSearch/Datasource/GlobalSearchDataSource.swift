import Foundation
import Networking
import Utility
import UIKit

fileprivate typealias SearchDataSource = UITableViewDiffableDataSource<GlobalSearchDataSource.Section, EmailMessage>
fileprivate typealias SearchSnapshot = NSDiffableDataSourceSnapshot<GlobalSearchDataSource.Section, EmailMessage>

final class GlobalSearchDataSource: NSObject {
    // MARK: Properties
    private weak var tableView: UITableView?
    
    private (set) var messages: [EmailMessage] = [] {
        didSet {
            defer {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.presenter?.turnOffLoading()
                    self.presenter?.updateEmptyState(shouldShow: self.messages.isEmpty)
                }
            }
            createSnapshot(from: messages)
            
            if messages.isEmpty {
                tableView?.tableFooterView = UIView()
            }
        }
    }
    
    private (set) var folders: [Folder] = []
    
    private var user = UserMyself()
    
    private weak var presenter: GlobalSearchPresenter?
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Constructor
    init(tableView: UITableView, presenter: GlobalSearchPresenter?) {
        self.tableView = tableView
        self.presenter = presenter
        super.init()
        
        self.tableView?.backgroundColor = .tertiarySystemGroupedBackground
        self.tableView?.separatorStyle = .none
        self.tableView?.estimatedRowHeight = UITableView.automaticDimension
        self.tableView?.keyboardDismissMode = .interactive
        self.tableView?.contentInsetAdjustmentBehavior = .never
        self.tableView?.tableFooterView = UIView()
        self.tableView?.register(UINib(nibName: SearchTableViewCell.className,
                                       bundle: Bundle(for: SearchTableViewCell.self)),
                                forCellReuseIdentifier: SearchTableViewCell.className)
        self.tableView?.delegate = self
        self.tableView?.dataSource = dataSource
    }
    
    // MARK: - Update
    func updateDatasource(by messages: [EmailMessage]) {
        self.messages = messages
    }
    
    func updateMessageStatus(message: EmailMessage, status: Bool) {
        if let index = messages.firstIndex(where: { $0.messsageID == message.messsageID }) {
            var message = messages[index]
            message.update(status)
            messages[index] = message
            createSnapshot(from: messages)
        }
    }
    
    private func createSnapshot(from messages: [EmailMessage]) {
        var snapshot = SearchSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(messages)
        dataSource.apply(snapshot, animatingDifferences: true)
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
extension GlobalSearchDataSource: UITableViewDelegate {
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

// MARK: - Diffable Datasource
private extension GlobalSearchDataSource {
    func makeDataSource() -> SearchDataSource {
        guard let tableView = self.tableView else {
            return UITableViewDiffableDataSource()
        }
        
        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { [weak self] (tableView, indexPath, message) in
                return self?.configureCell(for: indexPath, and: tableView) ?? UITableViewCell()
            }
        )
    }
    
    func configureCell(for indexPath: IndexPath, and tableView: UITableView) -> UITableViewCell {
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
}

fileprivate extension GlobalSearchDataSource {
    enum Section {
        case main
    }
}

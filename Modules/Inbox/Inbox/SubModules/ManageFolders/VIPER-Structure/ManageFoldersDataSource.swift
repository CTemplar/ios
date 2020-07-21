import Foundation
import UIKit
import Utility
import Networking

final class ManageFoldersDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    private var folders: [Folder] = [] {
        didSet {
            reloadData()
            onUpdateDataSource?(folders.isEmpty == false)
        }
    }
    
    var folderCount: Int {
        return folders.count
    }
    
    var isPrimeUser: Bool {
        return user?.isPrime == true
    }
    
    private var user: UserMyself?
 
    private var tableView: UITableView
    
    private weak var parentViewController: ManageFoldersViewController?
    
    private let formatterService = UtilityManager.shared.formatterService
    
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        return refreshControl
    }()
    
    var onUpdateDataSource: ((Bool) -> Void)?
    
    // MARK: - Constructor
    init(parent: ManageFoldersViewController,
         tableView: UITableView,
         folders: [Folder],
         user: UserMyself?) {
        self.parentViewController = parent
        self.folders = folders
        self.user = user
        self.tableView = tableView
        super.init()
        setupTableView()
        reloadData()
    }
    
    // MARK: - DataSource Updater
    func update(folders: [Folder]) {
        self.folders = folders
        NotificationCenter.default.post(name: .updateCustomFolderNotificationID, object: folders)
    }
    
    func add(folder: Folder) {
        folders.append(folder)
        reloadData()
        onUpdateDataSource?(folders.isEmpty == false)
        NotificationCenter.default.post(name: .updateCustomFolderNotificationID, object: folders)
    }
    
    func update(user: UserMyself?) {
        self.user = user
    }
    
    // MARK: - Setup
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(self.refreshControl)
        tableView.rowHeight = 50.0
        registerTableViewCell()
    }

    func registerTableViewCell() {
        tableView.register(UINib(nibName: MoveToFolderTableViewCell.className,
                                 bundle: Bundle(for: type(of: self))),
                           forCellReuseIdentifier: MoveToFolderTableViewCell.className
        )
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let folder = folders[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoveToFolderTableViewCell.className) as? MoveToFolderTableViewCell,
            let folderName = folder.folderName,
            let folderColor = folder.color else {
            return UITableViewCell()
        }
        
        cell.setupMoveToFolderTableCell(checked: false, iconColor: folderColor, title: folderName, showCheckBox: false)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let folder = folders[indexPath.row]
        parentViewController?.router?.showEditFolderViewController(folder: folder)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let folder = folders[indexPath.row]
        if (editingStyle == .delete) {
            if let folderID = folder.folderID {
                self.parentViewController?.presenter?.showDeleteFolderAlert(folderID: folderID)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return Strings.Inbox.deleteRow.localized
    }
    
    // MARK: - TableView Helpers
    func reloadData() {
        refreshControl.endRefreshing()
        tableView.reloadData()
    }

    @objc
    private func handleRefresh(_ refreshControl: UIRefreshControl) {
        parentViewController?.presenter?.interactor?.foldersList(silent: true)
    }
}

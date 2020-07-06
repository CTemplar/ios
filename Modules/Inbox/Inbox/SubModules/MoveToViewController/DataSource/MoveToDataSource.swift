import Foundation
import UIKit
import Networking
import Utility

class MoveToDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    private var tableView: UITableView
    private weak var parentViewController: MoveToViewController?
    var customFoldersArray: [Folder] = []
    var selectedFolderIndex: Int?
    
    // MARK: - Constructor
    init(parent: MoveToViewController, tableView: UITableView) {
        self.parentViewController = parent
        self.tableView = tableView
        
        super.init()
        
        setupTableView()
    }

    // MARK: - Setuo
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: MoveToFolderTableViewCell.className, bundle: Bundle(for: type(of: self))),
                           forCellReuseIdentifier: MoveToFolderTableViewCell.className
        )

        tableView.reloadData()
    }
    
    //MARK: - table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customFoldersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let folder = customFoldersArray[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoveToFolderTableViewCell.className,
                                                       for: indexPath) as? MoveToFolderTableViewCell,
            let folderName = folder.folderName else {
            return UITableViewCell()
        }
        
        let color = folder.color
        
        let selected = indexPath.row == self.selectedFolderIndex
        
        cell.setupMoveToFolderTableCell(checked: selected, iconColor: color!, title: folderName, showCheckBox: true)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedFolderIndex == indexPath.row {
            self.selectedFolderIndex = nil
        } else {
            self.selectedFolderIndex = indexPath.row
        }
        
        setApplyButtonEnabled()
        
        reloadData()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func setApplyButtonEnabled() {
        parentViewController?.presenter?.applyButton(enabled: selectedFolderIndex == nil ? false : true)
    }
}

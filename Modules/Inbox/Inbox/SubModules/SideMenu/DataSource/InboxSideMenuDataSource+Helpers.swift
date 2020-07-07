import Foundation
import Utility
import UIKit

extension InboxSideMenuDataSource {
    func didSelect(menu: Menu) {
        if SharedInboxState.shared.selectedMenu?.menuName == menu.menuName {
            return
        }
        
        SharedInboxState.shared.update(menu: menu)
        SharedInboxState.shared.update(preferences: nil)
        
        parentController?.presenter?.interactor?.onTapSideMenu(with: menu)
        tableView?.reloadData()
    }
    
    func didSelect(preferences: Menu.Preferences) {
        if preferences == .logout || preferences == .help {
            parentController?.presenter?.interactor?.onTapSideMenu(with: preferences)
        } else {
            if SharedInboxState.shared.selectedPreferences == preferences {
                return
            }
            
            SharedInboxState.shared.update(preferences: preferences)
            SharedInboxState.shared.update(menu: nil)

            parentController?.presenter?.interactor?.onTapSideMenu(with: preferences)
            tableView?.reloadData()
        }
    }
    
    func didSelectCustomFolder(at indexPath: IndexPath) {
        if SharedInboxState.shared.selectedCustomFolderIndexPath == indexPath {
            return
        }
        if self.showAllFolders {
            if indexPath.row < customFolders.count {
                let folder = customFolders[indexPath.row]
                let folderName = folder.folderName ?? ""
                SharedInboxState.shared.update(customFolderIndexPath: indexPath)
                parentController?.presenter?.interactor?.onTapCustomFolder(with: folderName)
            } else {
                showAllFolders = false
                SharedInboxState.shared.update(customFolderIndexPath: nil)
                tableView?.reloadData()
            }
        } else {
            if indexPath.row == Menu.customFoldersCount {
                showAllFolders = true
                tableView?.reloadData()
            } else {
                let folder = customFolders[indexPath.row]
                let folderName = folder.folderName ?? ""
                parentController?.presenter?.interactor?.onTapCustomFolder(with: folderName)
            }
        }
    }
}

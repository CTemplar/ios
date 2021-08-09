import Foundation
import UIKit
import Utility

class MoveToRouter {
    // MARK: Properties
    private weak var viewController: MoveToViewController?
    
    // MARK: - Constructor
    init(viewController: MoveToViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Navigations
    func showFoldersManagerViewController() {
        let manageFolderVC: ManageFoldersViewController = UIStoryboard(storyboard: .manageFolders,
                                                                bundle: Bundle(for: ManageFoldersViewController.self)
        ).instantiateViewController()

        manageFolderVC.setup(folderList: viewController?.dataSource?.customFoldersArray ?? [])
        manageFolderVC.showFromSideMenu = false
        manageFolderVC.setup(user: viewController?.user)
        manageFolderVC.showFromSideMenu = false
        
        let navigationController = InboxNavigationController(rootViewController: manageFolderVC)
        navigationController.modalPresentationStyle = .formSheet
        viewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func showAddFolderViewController() {
        let addFolderVC: AddFolderViewController = UIStoryboard(storyboard: .addFolder,
                                                                bundle: Bundle(for: AddFolderViewController.self)
        ).instantiateViewController()
        
        addFolderVC.modalPresentationStyle = .fullScreen
        viewController?.present(addFolderVC, animated: true, completion: nil)
    }
}

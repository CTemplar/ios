import Foundation
import UIKit
import Networking
import SideMenu

final class ManageFoldersRouter {
    // MARK: Properties
    private (set) weak var viewController: ManageFoldersViewController?

    // MARK: - Constructor
    init(viewController: ManageFoldersViewController) {
        self.viewController = viewController
    }
    
    func showInboxSideMenu() {
        viewController?.sideMenuController?.revealMenu()
    }
    
    func backAction() {
        
        if (self.viewController?.showFromSettings)! {
            self.viewController?.navigationController?.popViewController(animated: true)
        } else {
            self.viewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func showAddFolderViewController() {
        let addFolderVC: AddFolderViewController = UIStoryboard(storyboard: .addFolder,
                                                                bundle: Bundle(for: EditFolderViewController.self
            )
        ).instantiateViewController()
        
        addFolderVC.delegate = viewController?.presenter
        
        addFolderVC.modalPresentationStyle = .formSheet
        
        viewController?.present(addFolderVC, animated: true, completion: nil)
    }
    
    func showEditFolderViewController(folder: Folder) {
        let editFolderVC: EditFolderViewController = UIStoryboard(storyboard: .editFolder,
                                                                  bundle: Bundle(for: EditFolderViewController.self
            )
        ).instantiateViewController()
        
        editFolderVC.setup(folder: folder)
        
        viewController?.show(editFolderVC, sender: self)
    }
}

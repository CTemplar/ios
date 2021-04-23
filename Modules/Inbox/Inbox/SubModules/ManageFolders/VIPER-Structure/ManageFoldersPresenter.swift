import Foundation
import Utility
import UIKit
import Networking

final class ManageFoldersPresenter {
    // MARK: Properties
    private weak var viewController: ManageFoldersViewController?
    private (set) var interactor: ManageFoldersInteractor?
    
    // MARK: - Constructor
    init(viewController: ManageFoldersViewController,
         interactor: ManageFoldersInteractor) {
        self.viewController = viewController
        self.interactor = interactor
        initialiseUI()
    }
    
    // MARK: - Setup UI
    private func initialiseUI() {
        viewController?.navigationItem.title = Strings.Menu.manageFolders.localized
        viewController?.navigationController?.updateTintColor()
        initAddFolderLimitView()
        setAddFolderButton(enable: true)
        updateState()
    }
    
    func updateState() {
        let folderCount = viewController?.dataSource?.folderCount ?? 0
        toggleEmptyState(showEmptyState: folderCount == 0)
    }
    
    func toggleEmptyState(showEmptyState: Bool) {
        viewController?.emptyFolderStackView.isHidden = showEmptyState == false
    }
    
    func setupCloseButton() {
        viewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                                            target: self,
                                                                            action: #selector(backAction))
    }
    
    func setupNavigationLeftItem() {
        func menuItem() -> UIBarButtonItem {
            return UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"), style: .plain, target: self, action: #selector(menuAction))
        }
        
        if Device.IS_IPAD {
            let emptyButton = UIBarButtonItem(image: UIImage(), style: .done, target: self, action: nil)
            if UIDevice.current.orientation.isLandscape {
                viewController?.navigationItem.leftBarButtonItem = menuItem()
            } else {
                viewController?.navigationItem.leftBarButtonItem = menuItem()
            }
        } else {
            viewController?.navigationItem.leftBarButtonItem = menuItem()
        }
    }
    
    @objc
    private func backAction() {
        viewController?.router?.backAction()
    }
    
    @objc
    private func menuAction() {
        viewController?.router?.showInboxSideMenu()
    }
    
    func addFolderButtonPressed() {
        let folderCount = viewController?.dataSource?.folderCount ?? 0
        
        if folderCount > (GeneralConstant.customFoldersLimitForNonPremium - 1) {
            if viewController?.dataSource?.isPrimeUser == true {
                viewController?.router?.showAddFolderViewController()
            } else {
                showAddFolderLimitAlert()
            }
        } else {
            viewController?.router?.showAddFolderViewController()
        }
    }
    
    private func setupAddFolderButton() {
        let folderCount = viewController?.dataSource?.folderCount ?? 0

        if folderCount > (GeneralConstant.customFoldersLimitForNonPremium - 1) {
            setAddFolderButton(enable: (viewController?.dataSource?.isPrimeUser == true))
        } else {
            setAddFolderButton(enable: true)
        }
    }
    
    private func setAddFolderButton(enable: Bool) {
        viewController?.addFolderBarButtonItem.isEnabled = enable
    }
    
    // MARK: - Handle Folder Limitations
    func showDeleteFolderAlert(folderID: Int) {
        let params = AlertKitParams(
            title: Strings.ManageFolder.deleteFolderTitle.localized,
            message: Strings.ManageFolder.deleteFolder.localized,
            cancelButton: Strings.Button.cancelButton.localized,
            otherButtons: [
                Strings.Button.deleteButton.localized
            ]
        )
        
        viewController?.showAlert(with: params, onCompletion: { [weak self] (index) in
            switch index {
            case 0:
                DPrint("Cancel Delete")
            default:
                self?.interactor?.deleteFolder(folderID: folderID)
            }
        })
    }
   
    func showAddFolderLimitAlert() {
        viewController?.upgradeToPrimeView?.isHidden = !(self.viewController?.upgradeToPrimeView?.isHidden)!
    }
    
    func initAddFolderLimitView() {
        viewController?.upgradeToPrimeView = Bundle(for: type(of: self))
            .loadNibNamed("UpgradeToPrime",
                          owner: nil,
                          options: nil)?.first as? UpgradeToPrimeView
        
        let frame = CGRect(x: 0.0, y: 0.0, width: self.viewController!.view.frame.width, height: self.viewController!.view.frame.height)

        viewController?.upgradeToPrimeView?.frame = frame
       
        viewController?.navigationController?.view.addSubview((self.viewController?.upgradeToPrimeView)!)
        
        viewController?.upgradeToPrimeView?.isHidden = true
    }
}

// MARK: - AddFolderDelegate
extension ManageFoldersPresenter: AddFolderDelegate {
    func didAddFolder(_ folder: Folder) {
        viewController?.dataSource?.add(folder: folder)
        viewController?.updateState()
    }
}

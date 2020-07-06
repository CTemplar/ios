import Foundation
import Utility
import Networking

class ManageFoldersInteractor {
    // MARK: Properties
    private weak var viewController: ManageFoldersViewController?
    private let apiService = NetworkManager.shared.apiService
    
    // MARK: - Constructor
    init(viewController: ManageFoldersViewController) {
        self.viewController = viewController
    }
    
    // MARK: - API Calls
    func foldersList(silent: Bool) {
        if !silent {
            Loader.start()
        }
        apiService.customFoldersList(limit: 200, offset: 0) { [weak self] (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(let value):
                    if let folderList = value as? FolderList {
                        self?.setFoldersData(folderList: folderList)
                    }
                case .failure(let error):
                    DPrint("error:", error)
                    self?.viewController?.showAlert(with: Strings.AppError.foldersError.localized,
                                                    message: error.localizedDescription,
                                                    buttonTitle: Strings.Button.closeButton.localized
                    )
                }
                Loader.stop()
            }
        }
    }
    
    func deleteFolder(folderID: Int) {
        apiService.deleteCustomFolder(folderID: folderID.description) { [weak self] (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(let value):
                    DPrint("value:", value)
                    self?.foldersList(silent: false)
                case .failure(let error):
                    DPrint("error:", error)
                    self?.viewController?.showAlert(with: Strings.AppError.foldersError.localized,
                               message: error.localizedDescription,
                               buttonTitle: Strings.Button.closeButton.localized
                    )
                }
            }
        }
    }
    
    // MARK: - Application Updates
    func setFoldersData(folderList: FolderList) {
        if let folders = folderList.foldersList {
            viewController?.setup(folderList: folders)
            viewController?.updateState()
        }
    }
}

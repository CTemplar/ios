import Foundation
import Utility
import Networking

final class EditFolderInteractor {
    // MARK: Properties
    private weak var viewController: EditFolderViewController?
    
    private let apiService = NetworkManager.shared.apiService
    
    private let formatterService = UtilityManager.shared.formatterService
    
    // MARK: - Constructor
    init(viewController: EditFolderViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Application Handlers
    func setFolderProperties(folder: Folder) {
        if let name = folder.folderName {
            viewController?.setup(folderName: name)
            viewController?.folderNameTextField.text = name
        }
        
        if let color = folder.color {
            viewController?.setup(selectedHexColor: color)
        }
        viewController?.navigationItem.title = viewController?.folderName
    }
    
    func validateFolderName(text: String) {
        var nameValid = false
        
        if formatterService.validateFolderNameFormat(enteredName: text) {
            viewController?.setup(folderName: text)
            viewController?.darkLineView.backgroundColor = k_sideMenuColor
            nameValid = true
        } else {
            viewController?.darkLineView.backgroundColor = k_redColor
            nameValid = false
        }
        
        setSaveButton(enable: ((viewController?.selectedHexColor.count ?? 0) > 0) && nameValid)
    }
    
    func setSaveButton(enable: Bool) {
        viewController?.navigationItem.rightBarButtonItem?.isEnabled = enable
    }
    
    // MARK: - API Calls
    func updateCustomFolder(folderID: Int, name: String, colorHex: String) {
        apiService.updateCustomFolder(folderID: folderID.description, name: name, color: colorHex) { [weak self] (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success:
                    self?.viewController?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self?.viewController?.showAlert(with: Strings.AppError.foldersError.localized,
                               message: error.localizedDescription,
                               buttonTitle: Strings.Button.closeButton.localized
                    )
                }
            }
        }
    }
    
    func deleteFolder(folderID: Int) {
        apiService.deleteCustomFolder(folderID: folderID.description) { [weak self] (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(let value):
                    print("value:", value)
                    self?.viewController!.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("error:", error)
                    self?.viewController?.showAlert(with: Strings.AppError.foldersError.localized,
                               message: error.localizedDescription,
                               buttonTitle: Strings.Button.closeButton.localized
                    )
                }
            }
        }
    }
    
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
                DPrint("Delete")
                self?.deleteFolder(folderID: folderID)
            }
        })
    }
}

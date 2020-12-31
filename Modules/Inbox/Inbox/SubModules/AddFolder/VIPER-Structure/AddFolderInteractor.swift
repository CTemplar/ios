import Foundation
import Utility
import Networking

class AddFolderInteractor {
    // MARK: Properties
    private weak var viewController: AddFolderViewController?
    
    private let apiService = NetworkManager.shared.apiService
    
    private let formatterService = UtilityManager.shared.formatterService
    
    // MARK: - Constructor
    init(viewController: AddFolderViewController?) {
        self.viewController = viewController
    }
    
    // MARK: - Validations
    func validateFolderName(text: String?) {
        guard let text = text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            viewController?.darkLineView.backgroundColor = k_redColor
            setAddButton(enable: false)
            return
        }
        
        let nameValid = formatterService.validateFolderNameFormat(enteredName: text)

        viewController?.darkLineView.backgroundColor = nameValid ? k_sideMenuColor : k_redColor
        
        setAddButton(enable: nameValid && self.viewController?.selectedHexColor.isEmpty == false)
    }
    
    func validFolderName(text: String?) -> Bool {
        return formatterService.validateFolderNameFormat(enteredName: text ?? "")
    }
    
    func setAddButton(enable: Bool) {
        viewController?.addButton.isEnabled = enable
    }
    
    // MARK: - API Call
    func createCustomFolder(name: String, colorHex: String) {
        apiService.createCustomFolder(name: name, color: colorHex) { [weak self] (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(let value):
                    DPrint("value:", value)
                    if let folder = value as? Folder {
                        self?.viewController?.delegate?.didAddFolder(folder)
                    }
                    self?.viewController?.dismiss(animated: true, completion: nil)
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
}

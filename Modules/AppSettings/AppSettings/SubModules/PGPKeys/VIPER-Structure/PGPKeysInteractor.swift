import Foundation
import Utility
import Networking

class PGPKeysInteractor {
    // MARK: Properties
    private let apiService = NetworkManager.shared.apiService
    private (set) weak var parentController: PGPKeysViewController?
    
    // MARK: - Constructor
    init(parentController: PGPKeysViewController?) {
        self.parentController = parentController
    }
    
    // MARK: - API Calls
    func mailboxList() {
        Loader.start()
        apiService.mailboxesList(completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch result {
                case .success(let value):
                    let mailboxes = value as! Mailboxes
                    if let mailboxesList = mailboxes.mailboxesResultsList {
                        self?.parentController?.presenter?.updateMailbox(mailboxesList)
                    }
                case .failure(let error):
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        })
    }
    
    // MARK: - API Calls
    func extrakeysList() {
        Loader.start()
        apiService.keysList(completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch result {
                case .success(let value):
                    let mailboxes = value as! Mailboxes
                    if let mailboxesList = mailboxes.mailboxesResultsList {
                        self?.parentController?.presenter?.updateExtraKeys(mailboxesList)
                    }
                case .failure(let error):
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        })
    }
    
    // MARK: - API Calls
    func saveNewkeyOnServer(model: NewKeyModel) {
        
        apiService.createNewKey(model: model , completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch result {
                case .success(let value):
                    var mailbox = value as! Mailbox
                    mailbox.keyType = model.keyType
                    DispatchQueue.main.async {
                        self?.parentController?.presenter?.newKeyAdded(mailbox)
                    }
                case .failure(let error):
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        })
    }
    
    func getTrimmedUserName(name:String)-> String  {
      return  self.trimUserName(name)
    }
    
    private func trimUserName(_ userName: String) -> String {
        var trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let substrings = trimmedName.split(separator: "@")
        if let domain = substrings.last {
            if domain == Domain.main.rawValue || domain == Domain.dev.rawValue || domain == Domain.devOld.rawValue {
                if let name = substrings.first {
                    trimmedName = String(name)
                }
            }
        }
        return trimmedName
    }
}

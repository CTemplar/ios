//
//  AliasKeyInteractor.swift
//  AppSettings
//


import Foundation
import Utility
import Networking

class AliasKeyInteractor: NSObject ,HashingService {
    // MARK: Properties
    private let apiService = NetworkManager.shared.apiService
    private (set) weak var parentController: AliasKeysVC?
    
    // MARK: - Constructor
    init(parentController: AliasKeysVC?) {
        self.parentController = parentController
    }
    
    
    // MARK: - API Calls
    func setKeyAsPrimary(model: Mailbox) {
        Loader.start()
        apiService.setKeyAsPrimary(id:model.keyID ?? 0 , mailboxId: model.mailboxID ?? 0 , completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch result {
                case .success(_):
                    self?.parentController?.updateUI(isFromPrimary: true)
                case .failure(let error):
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        })
    }
    
    // MARK: - API Calls
    func deleteKey(model: Mailbox, password: String) {
        
        apiService.deleteKey(id: model.keyID ?? 0, password: password, completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch result {
                case .success(_):
                    self?.parentController?.updateUI(isFromPrimary: false)
                case .failure(let error):
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        })
    }
    
    func deleteKeyFromServer() {
        Loader.start()
        let pgpService = UtilityManager.shared.pgpService
        let password = pgpService.getPasswordFromKeychain()
        let trimmedUsername = self.trimUserName(self.parentController?.delegate?.getEmail() ?? "")
        
        generateHashedPassword(for: trimmedUsername, password: password) { [weak self] (result) in
            guard let self = self else {
                Loader.stop()
                return
            }
            guard let value = try? result.get() else {
                Loader.stop()
                return
            }
            self.deleteKey(model: self.parentController?.mailbox ?? Mailbox(), password: value)
        }
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

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
    
    // MARK: - PGP Helpers
    func createPgpPublicKeyFile(for mailbox: Mailbox) -> String{
        let fileName = "\(mailbox.email ?? "")_publicKey_\(mailbox.fingerprint ?? "").txt"
        let fileData = mailbox.publicKey ?? ""
        return createPgpKeyFile(with: fileName, and: fileData)
    }
    
    func createPgpPrivateKeyFile(for mailbox: Mailbox) -> String {
        let fileName = "\(mailbox.email ?? "")_privateKey_\(mailbox.fingerprint ?? "").txt"
        let fileData = mailbox.privateKey ?? ""
        return createPgpKeyFile(with: fileName, and: fileData)
    }
    
    private func createPgpKeyFile(with fileName: String, and fileData: String) -> String {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentDirectory.appendingPathComponent(fileName)
        do {
            try fileData.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
            return filePath.absoluteString
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
}

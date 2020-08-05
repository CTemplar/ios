import Foundation
import Utility
import Networking

final class EncryptionInteractor {
    // MARK: Properties
    private let apiService = NetworkManager.shared.apiService
    private weak var parentController: EncryptionController?
    
    // MARK: - Constructor
    init(parentController: EncryptionController) {
        self.parentController = parentController
    }
    
    // MARK: - API Calls
    func encryptOrDecryptItem(withSettings settings: Settings,
                              encryptionType: EncryptionType,
                              encryptSubject: Bool,
                              encryptContacts: Bool,
                              encryptAttachment: Bool,
                              onCompletion: @escaping ((Error?) -> Void)) {
        let settingsID = settings.settingsID ?? 0
        apiService.updateSettings(settingsID: settingsID,
                                  recoveryEmail: "",
                                  dispalyName: "",
                                  savingContacts: settings.saveContacts ?? false,
                                  encryptContacts: encryptContacts,
                                  encryptAttachment: encryptAttachment,
                                  encryptSubject: encryptSubject)
        { [weak self] (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(_):
                    if encryptionType == .contacts {
                        if encryptContacts {
                            NotificationCenter.default.post(name: .updateUserSettingsNotificationID, object: nil, userInfo: nil)
                            onCompletion(nil)
                        } else {
                            self?.startDecryption(onCompletion)
                        }
                    } else {
                        onCompletion(nil)
                    }
                case .failure(let error):
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                    onCompletion(error)
                }
            }
        }
    }
    
    private func startDecryption(_ onCompletion: @escaping ((Error?) -> Void)) {
        userContactsList(onCompletion)
    }
    
    private func userContactsList(_ onCompletion: @escaping ((Error?) -> Void)) {
        apiService.userContacts(fetchAll: true, offset: 0, silent: true) { [weak self] (result) in
            switch(result) {
            case .success(let value):
                if let contactsList = value as? ContactsList,
                    let contacts = contactsList.contactsList,
                    !contacts.isEmpty {
                    self?.decryptContacts(contacts: contacts, onCompletion)
                } else {
                    DPrint("No contacts to decrypt")
                    DispatchQueue.main.async {
                        onCompletion(nil)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                    onCompletion(error)
                }
            }
        }
    }
    
    private func decryptContacts(contacts: [Contact],
                                 _ onCompletion: @escaping ((Error?) -> Void)) {
        func onDecryptionCompleted() {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .updateUserSettingsNotificationID, object: nil, userInfo: nil)
                self.parentController?.showAlert(with: Strings.EncryptionDecryption.decryptContactsTitle.localized,
                                            message: Strings.EncryptionDecryption.allContactsWasDecrypted.localized,
                                            buttonTitle: Strings.Button.closeButton.localized
                )
            }
        }
        
        var decryptedContacts = 0
        
        for contact in contacts {
            self.decryptContact(contact) { [weak self] (done) in
                if done {
                    if decryptedContacts == contacts.count {
                        onDecryptionCompleted()
                        return
                    }
                    decryptedContacts += 1
                } else {
                    DispatchQueue.main.async {
                        // Something went wrong
                        self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                          message: Strings.AppError.contactEncryptionError.localized,
                                                          buttonTitle: Strings.Button.closeButton.localized)
                        let error = NSError(domain:"", code: 0, userInfo: [NSLocalizedDescriptionKey: ""])
                        onCompletion(error as Error)
                    }
                    return
                }
            }
        }
    }
    
    private func decryptContact(_ contact: Contact,
                                with completion: ((_ done: Bool) -> Void)? = nil) {
        let pgpService = UtilityManager.shared.pgpService
        if let encryptedData = contact.encryptedData {
            let decryptedContent = pgpService.decryptMessage(encryptedContet: encryptedData)
            let dictionary = self.convertStringToDictionary(text: decryptedContent)
            let decryptedContact = Contact(decryptedDictionary: dictionary, contactId: contact.contactID ?? 0)
            
            updateContact(contactID: contact.contactID?.description ?? "",
                          name: decryptedContact.contactName ?? "name",
                          email:  decryptedContact.email ?? "email",
                          phone: decryptedContact.phone ?? "",
                          address: decryptedContact.address ?? "",
                          note: decryptedContact.note ?? "") { (done) in
                            completion?(done)
            }
        }
    }
    
    private func updateContact(contactID: String,
                       name: String,
                       email: String,
                       phone: String,
                       address: String,
                       note: String,
                       with completion: ((_ done: Bool) -> Void)? = nil) {
        apiService.updateContact(contactID: contactID,
                                 name: name,
                                 email: email,
                                 phone: phone,
                                 address: address,
                                 note: note)
        { (result) in
            switch(result) {
            case .success:
                completion?(true)
            case .failure:
                completion?(false)
            }
        }
    }
    
    private func convertStringToDictionary(text: String) -> [String: Any] {
        var dicitionary: [String: Any] = [:]
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    dicitionary = json
                }
                return dicitionary
            } catch {
                DPrint("convertStringToDictionary: Something went wrong string ->", text)
                return dicitionary
            }
        }
        
        return dicitionary
    }
}

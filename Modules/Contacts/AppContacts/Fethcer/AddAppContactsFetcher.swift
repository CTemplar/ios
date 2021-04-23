import Foundation
import Networking
import Utility

final class AddAppContactsFetcher {
    // MARK: Properties
    lazy private var apiService: APIService = {
        return NetworkManager.shared.apiService
    }()

    // MARK: - API Handlers
    func updateContact(withContact contact: Contact, isEncrypted: Bool, onCompletion: @escaping ContactUpdateResponse) {
        guard let id = contact.contactID else {
            onCompletion(.failure(AppError.unknown))
            return
        }
        
        if isEncrypted {
            apiService.updateEncryptedContact(contactID: "\(id)", name: contact.contactName ?? "", email: contact.email ?? "", phone: contact.phone ?? "", address: contact.address ?? "", note: contact.note ?? "") { [weak self] (result) in
                self?.getCommonResponse(from: result, onCompletion: onCompletion)
            }
        } else {
            apiService.updateContact(contactID: "\(id)", name: contact.contactName ?? "", email: contact.email ?? "", phone: contact.phone ?? "", address: contact.address ?? "", note: contact.note ?? "") { [weak self] (result) in
                self?.getCommonResponse(from: result, onCompletion: onCompletion)
            }
        }
    }
    
    func createContact(_ contact: Contact, isEncrypted: Bool, onCompletion: @escaping ContactUpdateResponse) {
        if isEncrypted {
            apiService.createEncryptedContact(name: contact.contactName ?? "", email: contact.email ?? "", phone: contact.phone ?? "", address: contact.address ?? "", note: contact.note ?? "") { [weak self] (result) in
                
                self?.getCommonResponse(from: result, onCompletion: onCompletion)
            }
        } else {
            apiService.createContact(name: contact.contactName ?? "", email: contact.email ?? "", phone: contact.phone ?? "", address: contact.address ?? "", note: contact.note ?? "") { [weak self] (result) in
                self?.getCommonResponse(from: result, onCompletion: onCompletion)
            }
        }
    }
    
    func deleteContact(_ contact: Contact, onCompletion: @escaping ContactUpdateResponse) {
        guard let contactId = contact.contactID else {
            onCompletion(.failure(AppError.unknown))
            return
        }
        
        apiService.deleteContacts(contactsIDIn: "\(contactId)") { [weak self] (result) in
            self?.getCommonResponse(from: result, onCompletion: onCompletion)
        }
    }
    
    private func getCommonResponse(from result: APIResult<Any>, onCompletion: @escaping ContactUpdateResponse) {
        switch(result) {
        case .success(let value):
            onCompletion(.success(value))
        case .failure(let error):
            onCompletion(.failure(error))
        }
    }
}

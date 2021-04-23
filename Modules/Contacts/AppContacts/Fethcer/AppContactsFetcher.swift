import Foundation
import Networking
import Utility

final class AppContactsFetcher {
    // MARK: Properties
    private var totalItems = 0
    private var offset = 0
    let isContactEncrypted: Bool
    
    // MARK: - Constructor
    init(isContactEncrypted: Bool) {
        self.isContactEncrypted = isContactEncrypted
    }
    
    // MARK: - API Services
    func fetchAllContacts(onCompletion: @escaping ContactResponse) {
//        if  offset > 0 {
//            return
//        }
        
        let fetchAll = !isContactEncrypted

        NetworkManager.shared.apiService.userContacts(fetchAll: fetchAll, offset: offset, silent: false) { [weak self] (result) in
            guard let self = self else {
                onCompletion(.failure(AppError.unknown))
                return
            }
            
            switch(result) {
            case .success(let value):
                if let contactsList = value as? ContactsList, let contacts = contactsList.contactsList {
                    if let totalCount = contactsList.totalCount {
                        self.totalItems = totalCount
                    }
                    self.offset = self.offset + contactPageLimit
                    onCompletion(.success((contacts: contacts, didfetchAll: !fetchAll)))
                } else {
                    onCompletion(.failure(AppError.unknown))
                }
            case .failure(let error):
                onCompletion(.failure(AppError.serverError(value: error.localizedDescription)))
            }
        }
    }
    
    func deleteContacts(_ contacts: [Contact], onCompletion: @escaping ContactResponse) {
        var contactsIDList = ""
        
        for contact in contacts {
            if let contactId = contact.contactID?.description {
                contactsIDList = contactsIDList + contactId + ","
            }
        }
        
        contactsIDList.remove(at: contactsIDList.index(before: contactsIDList.endIndex))
        
        NetworkManager.shared.apiService.deleteContacts(contactsIDIn: contactsIDList) { [weak self] (result) in
            guard let self = self else {
                onCompletion(.failure(AppError.unknown))
                return
            }
            switch(result) {
            case .success(_):
                self.offset = 0
                self.fetchAllContacts(onCompletion: onCompletion)
            case .failure(let error):
                onCompletion(.failure(AppError.serverError(value: error.localizedDescription)))
            }
        }
    }
}

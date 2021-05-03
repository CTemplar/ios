import Foundation
import Networking
import Utility
import Combine
import PGPFramework

final class AppContactsViewModel: Modelable {
    // MARK: Properties
    private (set) var errorMetadata = PassthroughSubject<(title: String, message: String), Never>()

    private var isContactEncrypted: Bool
    
    private var user: UserMyself
    
    @Published private (set) var contacts: [Contact] = []
    
    private var originalContacts: [Contact] = []
    private var tempraryContacts: [Contact] = []
    
    
    private var fetcher: AppContactsFetcher!
    
    private var selectedContacts: [Contact] = []
 
    var shouldShowSearchControl: Bool {
        return isContactEncrypted == false
    }
    
    lazy var noSearchResultsText: String = {
        return Strings.Search.noResults.localized
    }()
    
    lazy var noContactsText: String = {
        return Strings.Contacts.noContacts.localized
    }()
    
    var contactEncrypted: Bool {
        return isContactEncrypted
    }
    
    var numberOfContacts = 0
    var countDecryptedContacts = 0
    
    private (set) var shouldEnableTrash = CurrentValueSubject<Bool, Never>(false)
    
    // MARK: - Initializer
    init(user: UserMyself) {
        self.user = user
        self.isContactEncrypted = user.settings.isContactsEncrypted ?? false
        self.fetcher = AppContactsFetcher(isContactEncrypted: isContactEncrypted)
    }
    
    // MARK: - Setup
    func filterContacts(byPrefix prefix: String, contacts: [Contact]) -> [Contact] {
        let filteredContacts = contacts.filter({ $0.contactName?.lowercased().hasPrefix(prefix.lowercased()) == true })
        return filteredContacts
    }
    
    // MARK: - Helpers
    func setFilteredList(searchText: String) {
        let filteredContactNamesList = (originalContacts.filter({( contact: Contact) -> Bool in
            return (contact.contactName?.lowercased().contains(searchText.lowercased()) ?? false)
        }))
        
        let filteredEmailsList = (originalContacts.filter({( contact: Contact) -> Bool in
            return (contact.email?.lowercased().contains(searchText.lowercased()) ?? false)
        }))
        
        let filteredList = (filteredContactNamesList + filteredEmailsList)
        
        contacts = filteredList.removingDuplicates()
    }
    
    func clearFilter() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.contacts = self.originalContacts
        }
    }
    
    // MARK: - API Handlers
    func fetchContacts() {
        fetcher.fetchAllContactsFromComposeMail { [weak self] (result) in
            guard let self = self else {
                return
            }
            if (result != nil) {
                self.parseResponse(from: result)
            }
        }
    }
    
    func delete(contacts: [Contact]) {
        fetcher.deleteContacts(contacts) { [weak self] (result) in
            guard let self = self else {
                return
            }
            self.parseResponse(from: result)
        }
    }
    
    private func parseResponse(from result: APIResult<(contacts: [Contact], didfetchAll: Bool)>) {
        
        DispatchQueue.main.async {
            Loader.stop()
        }
        switch result {
        case .success(let response):
            var existingContacts = self.contacts
            if response.didfetchAll {
                existingContacts.append(contentsOf: response.contacts)
            } else {
                existingContacts = response.contacts
            }
            DispatchQueue.main.async {
                Loader.stop()
                Loader.start()
            }
            self.numberOfContacts = existingContacts.count
            self.countDecryptedContacts = 0
            self.tempraryContacts = []
            self.updateContacts(contacts: existingContacts)
           
        case .failure(let error):
            self.errorMetadata.send((title: Strings.AppError.error.localized, message: error.localizedDescription))
        }
    }

    private func updateContacts(contacts:[Contact]) {
        
        for contactsResult in contacts {
            if contactsResult.isEncrypted ?? false {
                if let unwrappedData = contactsResult.encryptedData {
                    DispatchQueue.global(qos: .utility).async {
                        self.decryptContactData(encryptedData: unwrappedData, contact: contactsResult)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.tempraryContacts.append(contactsResult)
                    self.countDecryptedContacts = self.countDecryptedContacts + 1
                    if (self.numberOfContacts == self.countDecryptedContacts) {
                        self.contacts = self.tempraryContacts
                        self.selectedContacts = self.contacts
                        Loader.stop()
                    }
//                    self.contacts = existingContacts
                   
                }
            }
        }
    }
    
    func decryptContactData(encryptedData: String, contact: Contact)  {
        guard let decryptedContent = self.decrypt(content: encryptedData) else {
            DPrint("Nothing")
            self.countDecryptedContacts = self.countDecryptedContacts + 1
            if (self.numberOfContacts == self.countDecryptedContacts) {
                self.contacts = self.tempraryContacts
                self.selectedContacts = self.contacts
                Loader.stop()
            }
            return
        }
        let dictionary = self.convertStringToDictionary(text: decryptedContent)
        let encryptedContact = Contact(encryptedDictionary: dictionary, contactId: contact.contactID ?? 0, encryptedData: contact.encryptedData ?? "")
        
        DispatchQueue.main.async {
            self.tempraryContacts.append(encryptedContact)
            self.countDecryptedContacts = self.countDecryptedContacts + 1
            if (self.numberOfContacts == self.countDecryptedContacts) {
                self.contacts = self.tempraryContacts
                self.selectedContacts = self.contacts
                Loader.stop()
            }
        }
    }
    
    // MARK: - decrypt Contact
     func decrypt(content: String) -> String? {
        let password = UtilityManager.shared.keychainService.getPassword()
        if let contentData = content.data(using: .ascii) {
            if let data =  PGPEncryption().decryptSimpleMessage(encrypted: contentData, userPassword: password) {
                return  String(decoding: data, as: UTF8.self)
            }
        }
        else {
            return nil
        }
        return nil
    }
    
    
    private func convertStringToDictionary(text: String) -> [String:Any] {
        var dicitionary = [String: Any]()
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
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

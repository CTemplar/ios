import Foundation
import Networking
import Utility
import Combine

final class AppContactsViewModel: Modelable {
    // MARK: Properties
    private (set) var errorMetadata = PassthroughSubject<(title: String, message: String), Never>()

    private var isContactEncrypted: Bool
    
    private var user: UserMyself
    
    @Published private (set) var contacts: [Contact] = []
    
    private var originalContacts: [Contact] = []
    
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
        fetcher.fetchAllContacts { [weak self] (result) in
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
            self.originalContacts = existingContacts
            self.contacts = existingContacts
        case .failure(let error):
            self.errorMetadata.send((title: Strings.AppError.error.localized, message: error.localizedDescription))
        }
    }
}

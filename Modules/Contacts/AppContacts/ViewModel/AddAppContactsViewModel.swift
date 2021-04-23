import Foundation
import Combine
import Utility
import Networking

final class AddAppContactsViewModel: Modelable {
    // MARK: Properties
    @Published private (set) var contactName = ""
    @Published private (set) var contactEmailAddress = ""
    @Published private (set) var contactPhoneNumber = ""
    @Published private (set) var contactAddress = ""
    @Published private (set) var contactNote = ""
    @Published private (set) var hideDeleteContactOption = true
    @Published private (set) var enableSaveOption = false
    private (set) var onUpdateContact = PassthroughSubject<Bool, Error>()
    
    enum Mode {
        case Add
        case Edit
    }
    
    private var contact: Contact
    private var editMode: Mode
    private var isContactEncrypted: Bool
    
    var navigationTitle: String {
        return editMode == .Edit ? "Edit Contact" : "Add Contact"
    }
    
    private let fetcher = AddAppContactsFetcher()

    // MARK: - Constructor
    init(contact: Contact, mode: Mode, isContactEncrypted: Bool) {
        self.contact = contact
        self.editMode = mode
        self.isContactEncrypted = isContactEncrypted
        
        configureOutput()
        
        toggleSaveOption()
    }
    
    // MARK: Setup Datasource
    private func configureOutput() {
        contactName = contact.contactName ?? ""
        contactEmailAddress = contact.email ?? ""
        contactPhoneNumber = contact.phone ?? ""
        contactAddress = contact.address ?? ""
        contactNote = contact.note ?? ""
        hideDeleteContactOption = editMode == .Add
    }
    
    func update(name: String) {
        contact.update(name: name)
        toggleSaveOption()
    }
    
    func update(email: String) {
        contact.update(email: email)
        toggleSaveOption()
    }
    
    func update(phone: String) {
        contact.update(phone: phone)
    }
    
    func update(address: String) {
        contact.update(address: address)
    }
    
    func update(note: String) {
        contact.update(note: note)
    }
    
    // MARK: - Helpers
    private func toggleSaveOption() {
        guard let name = contact.contactName, !name.isEmpty else {
            enableSaveOption = false
            return
        }
        
        guard let email = contact.email,
              !email.isEmpty,
              UtilityManager.shared.formatterService.validateEmailFormat(enteredEmail: email) else {
            enableSaveOption = false
            return
        }

        enableSaveOption = true
    }
    
    // MARK: - API Calls
    func saveContact() {
        switch editMode {
        case .Add:
            fetcher.createContact(contact, isEncrypted: isContactEncrypted, onCompletion: { [weak self] (result) in
                self?.parseResponse(from: result)
            })
        case .Edit:
            fetcher.updateContact(withContact: contact, isEncrypted: isContactEncrypted, onCompletion: { [weak self] (result) in
                
                self?.parseResponse(from: result)
            })
        }
    }
    
    func deleteContact() {
        fetcher.deleteContact(contact) { [weak self] (result) in
           
            self?.parseResponse(from: result)
        }
    }
    
    private func parseResponse(from result: APIResult<Any>) {
        DispatchQueue.main.async {
            Loader.stop()
        }
        switch result {
        
        case .success:
            onUpdateContact.send(true)
        case .failure(let error):
            onUpdateContact.send(completion: .failure(error))
        }
    }
}


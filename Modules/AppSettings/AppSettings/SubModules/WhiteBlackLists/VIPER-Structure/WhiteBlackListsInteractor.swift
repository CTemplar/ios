import Foundation
import Utility
import Networking

final class WhiteBlackListsInteractor {
    
    // MARK: Properties
    private weak var viewController: WhiteBlackListsViewController?
    
    private weak var presenter: WhiteBlackListsPresenter?
    
    let apiService = NetworkManager.shared.apiService
    
    // MARK: - Constructor
    init(viewController: WhiteBlackListsViewController?) {
        self.viewController = viewController
    }
    
    // MARK: - Setup
    func setup(presenter: WhiteBlackListsPresenter?) {
        self.presenter = presenter
    }
    
    // MARK: - API Calls
    func getWhiteListContacts(silent: Bool) {
        if !silent {
            Loader.start()
        }
        apiService.whiteListContacts() { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                guard let safeSelf = self else { return }
                switch(result) {
                case .success(let value):
                    let contactsList = value as! ContactsList
                    if let contacts = contactsList.contactsList {
                        safeSelf.presenter?.update(whiteListContacts: contacts)
                        if let listMode = safeSelf.viewController?.listMode {
                            safeSelf.presenter?.setupTableAndDataSource(listMode: listMode)
                        }
                    }
                case .failure(let error):
                    safeSelf.viewController?.showAlert(with: Strings.AppError.error.localized,
                                                       message: error.localizedDescription,
                                                       buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }
    
    func getBlackListContacts(silent: Bool) {
        if !silent {
            Loader.start()
        }
        
        apiService.blackListContacts() { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                guard let safeSelf = self else { return }
                switch(result) {
                case .success(let value):
                    let contactsList = value as! ContactsList
                    if let contacts = contactsList.contactsList {
                        safeSelf.presenter?.update(blackListContacts: contacts)
                        if let listMode = safeSelf.viewController?.listMode {
                            safeSelf.presenter?.setupTableAndDataSource(listMode: listMode)
                        }
                    }
                case .failure(let error):
                    safeSelf.viewController?.showAlert(with: Strings.AppError.error.localized,
                                                       message: error.localizedDescription,
                                                       buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }
    
    func setFilteredList(searchText: String) {
        let contacts = viewController?.dataSource?.contacts ?? []
        
        let filteredContactNamesList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.contactName?.lowercased().contains(searchText.lowercased()) ?? false)
        }))
        
        let filteredEmailsList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.email?.lowercased().contains(searchText.lowercased()) ?? false)
        }))
        
        let filteredList = filteredContactNamesList + filteredEmailsList
        
        updateDataSource(searchText: searchText, filteredList: filteredList.removingDuplicates())
    }
    
    func updateDataSource(searchText: String, filteredList: Array<Contact>) {
        viewController?.dataSource?.update(filtered: presenter?.isFiltering ?? false)
        viewController?.dataSource?.update(filteredContacts: filteredList)
        viewController?.dataSource?.update(searchText: searchText)
        viewController?.dataSource?.reloadData()
    }
    
    func addContactToBlackList(name: String, email: String) {
        Loader.start()
        apiService.addContactToBlackList(name: name, email: email) { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                guard let safeSelf = self else { return }
                switch(result) {
                case .success:
                    safeSelf.getBlackListContacts(silent: false)
                case .failure(let error):
                    safeSelf.viewController?.showAlert(with: Strings.AppError.error.localized,
                                                       message: error.localizedDescription,
                                                       buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }
    
    func addContactToWhiteList(name: String, email: String) {
        Loader.start()
        apiService.addContactToWhiteList(name: name, email: email) { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                guard let safeSelf = self else { return }
                switch(result) {
                case .success:
                    safeSelf.getWhiteListContacts(silent: false)
                case .failure(let error):
                    safeSelf.viewController?.showAlert(with: Strings.AppError.error.localized,
                                                       message: error.localizedDescription,
                                                       buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }
    
    
    func deleteContactsFromWhiteList(contactID: String) {
        Loader.start()
        apiService.deleteContactFromWhiteList(contactID: contactID) { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                guard let safeSelf = self else { return }
                switch(result) {
                case .success( _):
                    safeSelf.getWhiteListContacts(silent: false)
                case .failure(let error):
                    safeSelf.viewController?.showAlert(with: Strings.AppError.error.localized,
                                                       message: error.localizedDescription,
                                                       buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }
    
    func deleteContactsFromBlacklList(contactID: String) {
        Loader.start()
        apiService.deleteContactFromBlackList(contactID: contactID) { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                guard let safeSelf = self else { return }
                switch(result) {
                case .success( _):
                    safeSelf.getBlackListContacts(silent: false)
                case .failure(let error):
                    safeSelf.viewController?.showAlert(with: Strings.AppError.error.localized,
                                                       message: error.localizedDescription,
                                                       buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }
}

//
//  WhiteBlackListsPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import UIKit
import Networking

class WhiteBlackListsPresenter: NSObject {
    
    // MARK: Properties
    private (set) weak var viewController: WhiteBlackListsViewController?
    
    private (set) var interactor: WhiteBlackListsInteractor?
    
    private (set) var whiteListContacts: [Contact] = []
    
    private (set) var blackListContacts: [Contact] = []
    
    private let formatter = UtilityManager.shared.formatterService
    
    private var searchActive = false
    
    private var nameTextChangeProtocol: NSObjectProtocol?
    private var emailTextChangeProtocol: NSObjectProtocol?

    private var name = ""
    private var email = ""
    
    var isFiltering: Bool {
        return searchActive && searchController.searchBar.text?.isEmpty == false
    }
    
    lazy private (set) var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.insertSegment(withTitle: Strings.WhiteBlackListContact.whitelist.localized.lowercased().firstUppercased, at: 0, animated: true)
        segment.insertSegment(withTitle: Strings.WhiteBlackListContact.blacklist.localized.lowercased().firstUppercased, at: 1, animated: true)
        segment.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.withType(.ExtraSmall(.Bold)),
            NSAttributedString.Key.foregroundColor: k_sideMenuTextFadeColor
            ], for: .normal)
        segment.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.withType(.ExtraSmall(.Bold)),
            NSAttributedString.Key.foregroundColor: k_redColor
            ], for: .selected)
        segment.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return segment
    }()
    
    private (set) lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.delegate = self
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        return search
    }()
    
    // MARK: - Constructor
    init(viewController: WhiteBlackListsViewController?, interactor: WhiteBlackListsInteractor?) {
        self.viewController = viewController
        self.interactor = interactor
    }
    
    // MARK: - Update
    func update(whiteListContacts: [Contact]) {
        self.whiteListContacts = whiteListContacts
    }
    
    func update(blackListContacts: [Contact]) {
        self.blackListContacts = blackListContacts
    }
    
    func updateAddButtonTitle(basedOnMode listMode: WhiteBlackListsMode) {
        let buttonTitle = listMode == .whiteList ? Strings.WhiteBlackListContact.addWhiteList.localized : Strings.WhiteBlackListContact.addBlackList.localized
        viewController?.addContactButton.setTitle(buttonTitle, for: .normal)
    }
    
    // MARK: - UI Setup
    func setupSearchController() {
        viewController?.definesPresentationContext = true
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = Strings.Search.search.localized
        viewController?.navigationItem.searchController = searchController
        viewController?.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupTableAndDataSource(listMode: WhiteBlackListsMode) {
        let contactsList = listMode == .whiteList ? whiteListContacts : blackListContacts
        if !contactsList.isEmpty {
            viewController?.textLabel.isHidden = true
            setupSearchController()
        } else {
            viewController?.textLabel.isHidden = false
            searchController.isActive = false
            viewController?.navigationItem.searchController = nil
        }
        viewController?.dataSource?.update(contacts: contactsList)
        viewController?.dataSource?.reloadData()
    }

    func setup() {
        viewController?.navigationItem.title = Strings.WhiteBlackListContact.whitelistBlacklist.localized
        setupSegmentControl()
    }
    
    private func setupSegmentControl() {
        segmentControl.selectedSegmentIndex = 0
        viewController?.navigationItem.titleView = segmentControl
        
        segmentedControlValueChanged(segmentControl)
    }

    func setupLabelText(listMode: WhiteBlackListsMode) {
        var text = ""
        var textWithAttribute = ""
        
        switch listMode {
        case .whiteList:
            text = Strings.WhiteBlackListContact.whiteListText.localized
            textWithAttribute = Strings.WhiteBlackListContact.whiteListAttributedText.localized
        case .blackList:
            text = Strings.WhiteBlackListContact.blackListText.localized
            textWithAttribute = Strings.WhiteBlackListContact.blackListAttributedText.localized
        }
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)!,
            .foregroundColor: k_whiteBlackListTextLabelColor,
            .kern: 0.0
            ])
        
        _ = attributedString.setFont(textToFind: textWithAttribute,
                                     font: AppStyle.CustomFontStyle.Bold.font(withSize: 16.0)!)
        
        viewController?.textLabel.attributedText = attributedString
    }

    // MARK: - Actions
    func addContactButtonPressed(listMode: WhiteBlackListsMode) {
        let title = listMode == .whiteList ? Strings.WhiteBlackListContact.addContactW.localized : Strings.WhiteBlackListContact.addBlackList.localized
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)

        let loginAction = UIAlertAction(title: Strings.Button.saveButton.localized, style: .default) { [unowned self] (_) in
            guard let name = alert.textFields?.first?.text,
                let email = alert.textFields?[1].text
                else { return } // Should never happen
            self.viewController?.addAction(name: name, email: email)
            self.name = ""
            self.email = ""
        }
        
        alert.addTextField { [weak self] (textField) in
            textField.placeholder = Strings.WhiteBlackListContact.name.localized
            self?.nameTextChangeProtocol = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                                                  object: textField,
                                                                                  queue: OperationQueue.main) { (_) in
                                                                                    self?.name = textField.text ?? ""
                                                                                    loginAction.isEnabled = self?.textDidChangeInContactSavingAlert() ?? false
                                                    
            }
        }

        alert.addTextField { [weak self] (textField) in
            textField.placeholder = Strings.Login.emailPlaceholder.localized
            self?.emailTextChangeProtocol = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                                                   object: textField,
                                                                                   queue: OperationQueue.main) { [weak self] (_) in
                                                                                    self?.email = textField.text ?? ""
                                                                                    loginAction.isEnabled = self?.textDidChangeInContactSavingAlert() ?? false
            }
        }

        alert.addAction(UIAlertAction(title: Strings.Button.cancelButton.localized, style: .cancel))

        loginAction.isEnabled = false
        alert.addAction(loginAction)
        viewController?.present(alert, animated: true)
    }
    
    func deleteContactFromList(contactID: String, listMode: WhiteBlackListsMode) {
        let message = listMode == .whiteList ?
            Strings.WhiteBlackListContact.deleteContactFromWhiteList.localized :
            Strings.WhiteBlackListContact.deleteContactFromBlackList.localized

        let params = AlertKitParams(
            title: Strings.Inbox.Alert.deleteTitle.localized,
            message: message,
            cancelButton: Strings.Button.cancelButton.localized,
            otherButtons: [Strings.Button.deleteButton.localized]
        )
        
        viewController?.showAlert(with: params, onCompletion: { [weak self] (index) in
            switch index {
            case 0:
                DPrint("Cancel Delete Contact")
            default:
                DPrint("Delete Contact")
                switch listMode {
                case WhiteBlackListsMode.whiteList:
                    self?.interactor?.deleteContactsFromWhiteList(contactID: contactID)
                case WhiteBlackListsMode.blackList:
                    self?.interactor?.deleteContactsFromBlacklList(contactID: contactID)
                }
            }
        })
    }
    
    @objc
    private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = segmentControl.selectedSegmentIndex
        let listMode: WhiteBlackListsMode = selectedIndex == WhiteBlackListsMode.whiteList.rawValue ? .whiteList : .blackList
        viewController?.listMode = listMode
        
        searchController.isActive = false
        searchController.searchBar.text = ""
        interactor?.setFilteredList(searchText: "")
                
        name = ""
        email = ""
        
        NotificationCenter.default.removeObserver(self)
        nameTextChangeProtocol = nil
        emailTextChangeProtocol = nil

        updateAddButtonTitle(basedOnMode: listMode)
        setupLabelText(listMode: listMode)
        setupTableAndDataSource(listMode: listMode)
    }
}
// MARK: - UISearchResultsUpdating
extension WhiteBlackListsPresenter: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        interactor?.setFilteredList(searchText: searchController.searchBar.text ?? "")
    }
}

// MARK: - Searchbar Delegates
extension WhiteBlackListsPresenter: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
}

private extension WhiteBlackListsPresenter {
    func isValidEmail(_ email: String) -> Bool {
        return UtilityManager.shared.formatterService.validateNameLench(enteredName: email) && UtilityManager.shared.formatterService.validateEmailFormat(enteredEmail: email)
    }

    func isValidName(_ name: String) -> Bool {
        return UtilityManager.shared.formatterService.validateNameLench(enteredName: name)
    }

    func textDidChangeInContactSavingAlert() -> Bool {
        isValidName(name) && isValidEmail(email)
    }
}

//
//  WhiteBlackListsPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class WhiteBlackListsPresenter {
    
    var viewController   : WhiteBlackListsViewController?
    var interactor       : WhiteBlackListsInteractor?
    
    var whiteListContacts = Array<Contact>()
    var blackListContacts = Array<Contact>()
    
    func setupSearchBar(searchBar: UISearchBar) {
        
        searchBar.delegate = self.viewController
        
        searchBar.placeholder = "search".localized()
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).leftViewMode = .never
        UISearchBar.appearance().searchTextPositionAdjustment = UIOffset(horizontal: 52, vertical: 0)
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.borderStyle = .none
        }else {
            if let searchTextField = searchBar.value(forKey: "_searchField") as? UITextField {
                searchTextField.borderStyle = .none
            }
        }
        
        let imageView = UIImageView(image: UIImage(named: "SearchButton"))
        imageView.frame = CGRect(x: 16, y: 14, width: 22, height: 28)
        searchBar.add(subview: imageView)
    }
    
    func setupTableAndDataSource(listMode: WhiteBlackListsMode) {
        
        var contactsList = Array<Contact>()
        
        switch listMode {
        case WhiteBlackListsMode.whiteList:
            contactsList = whiteListContacts
            break
        case WhiteBlackListsMode.blackList:
            contactsList = blackListContacts
            break
        }
        
        if contactsList.count > 0 {
            self.viewController?.tableView.isHidden = false
            self.viewController?.searchBar.isHidden = false
            self.viewController?.addButtonView.isHidden = false
        } else {
            self.viewController?.tableView.isHidden = true
            self.viewController?.searchBar.isHidden = true
            self.viewController?.addButtonView.isHidden = true
        }
        
        self.viewController?.dataSource?.contactsArray = contactsList
        self.viewController?.dataSource?.reloadData()
    }
    
    func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        let selectedIndex = self.viewController!.segmentedControl.selectedSegmentIndex
        
        switch selectedIndex {
        case WhiteBlackListsMode.whiteList.rawValue:
            self.viewController!.listMode = WhiteBlackListsMode.whiteList
            break
        case WhiteBlackListsMode.blackList.rawValue:
            self.viewController!.listMode = WhiteBlackListsMode.blackList
            break
        default:
            break
        }
        
        self.viewController?.searchBarCancelButtonClicked((self.viewController?.searchBar)!)
        self.viewController?.searchBar.text = ""
        self.viewController?.presenter?.interactor?.setFilteredList(searchText: "")
        
        self.setupUnderlineView(listMode: self.viewController!.listMode)
        self.setupLabelText(listMode: self.viewController!.listMode)
        self.setupAddContactButton(listMode: self.viewController!.listMode)
        
        self.setupTableAndDataSource(listMode: self.viewController!.listMode)
    }

    func setupSegmentedControl() {
        
        self.viewController!.segmentedControl.setTitle("whitelist".localized(), forSegmentAt: 0)
        self.viewController!.segmentedControl.setTitle("blacklist".localized(), forSegmentAt: 1)
        
        self.viewController!.segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: k_latoRegularFontName, size: 14)!,
            NSAttributedString.Key.foregroundColor: k_sideMenuTextFadeColor
            ], for: .normal)
        
        self.viewController!.segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: k_latoBoldFontName, size: 14)!,
            NSAttributedString.Key.foregroundColor: k_redColor
            ], for: .selected)
        
    }
    
    func setupUnderlineView(listMode: WhiteBlackListsMode) {
        
        let width = self.viewController!.view.frame.width / 2.0
        self.viewController!.underlineWidthConstraint.constant = width
        
        switch listMode {
        case WhiteBlackListsMode.whiteList:
            self.viewController!.underlineLeftOffsetConstraint.constant = 0.0
            break
        case WhiteBlackListsMode.blackList:
            self.viewController!.underlineLeftOffsetConstraint.constant = width
            break
        }
    }
    
    func setupLabelText(listMode: WhiteBlackListsMode) {
        
        var text : String = ""
        var textWithAttribute : String = ""
        
        switch listMode {
        case WhiteBlackListsMode.whiteList:
            text = "whiteListText".localized()
            textWithAttribute = "whiteListAttributedText".localized()
            break
        case WhiteBlackListsMode.blackList:
            text = "blackListText".localized()
            textWithAttribute = "blackListAttributedText".localized()
            break
        }
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 16.0)!,
            .foregroundColor: k_lightGrayColor,
            .kern: 0.0
            ])
        
        _ = attributedString.setFont(textToFind: textWithAttribute, font: UIFont(name: k_latoBoldFontName, size: 16.0)!)
        
        self.viewController!.textLabel.attributedText = attributedString
    }
    
    func setupAddContactButton(listMode: WhiteBlackListsMode) {
        
        var text : String = ""
        
        switch listMode {
        case WhiteBlackListsMode.whiteList:
            text = "addWhiteList".localized()
            break
        case WhiteBlackListsMode.blackList:
            text = "addBlackList".localized()
            break
        }
        
        self.viewController!.addContactBottomButton.setTitle(text, for: .normal)
        self.viewController!.addContactButton.setTitle(text, for: .normal)
    }
    
    func addContactButtonPressed(listMode: WhiteBlackListsMode) {
        
        self.viewController?.router?.showAddContactToWhiteBlackList(mode: listMode)
    }
    
    func deleteContactFromList(contactID: String, listMode: WhiteBlackListsMode) {
   
        var message: String = ""
        
        switch listMode {
        case WhiteBlackListsMode.whiteList:
            message = "deleteContactFromWhiteList".localized()
            break
        case WhiteBlackListsMode.blackList:
            message = "deleteContactFromBlackList".localized()
            break
        }
        
        let params = Parameters(
            title: "deleteTitle".localized(),
            message: message,
            cancelButton: "cancelButton".localized(),
            otherButtons: ["deleteButton".localized()]
        )
        
        AlertHelperKit().showAlertWithHandler(self.viewController!, parameters: params) { buttonIndex in
            switch buttonIndex {
            case 0:
                print("Cancel Delete")
            default:
                print("Delete")
                switch listMode {
                case WhiteBlackListsMode.whiteList:
                    self.interactor?.deleteContactsFromWhiteList(contactID: contactID)
                    break
                case WhiteBlackListsMode.blackList:
                    self.interactor?.deleteContactsFromBlacklList(contactID: contactID)
                    break
                }
            }
        }
    }
}

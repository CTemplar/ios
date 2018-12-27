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
    
    func setupTableAndDataSource(user: UserMyself, listMode: WhiteBlackListsMode) {
        
        var contactsList = Array<Contact>()
        
        switch listMode {
        case WhiteBlackListsMode.whiteList:
            if let whiteListContacts = user.contactsWhiteList {
                contactsList = whiteListContacts
            }
            break
        case WhiteBlackListsMode.blackList:
            if let blackListContacts = user.contactsBlackList {
                contactsList = blackListContacts
            }
            break
        }
        
        if contactsList.count > 0 {
            self.viewController?.tableView.isHidden = false
        } else {
            self.viewController?.tableView.isHidden = true
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
        
        self.setupUnderlineView(listMode: self.viewController!.listMode)
        self.setupLabelText(listMode: self.viewController!.listMode)
        self.setupAddContactButton(listMode: self.viewController!.listMode)
        self.setupTableAndDataSource(user: self.viewController!.user, listMode: self.viewController!.listMode)
    }

    func setupSegmentedControl() {
        
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
        
        self.viewController!.addContactButton .setTitle(text, for: .normal)
    }
}

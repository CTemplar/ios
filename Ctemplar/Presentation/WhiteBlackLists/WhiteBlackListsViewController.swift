//
//  WhiteBlackListsViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

enum WhiteBlackListsMode: Int {
    
    case whiteList   = 0
    case blackList   = 1
}

class WhiteBlackListsViewController: UIViewController {
    
    @IBOutlet var tableView             : UITableView!
    
    @IBOutlet var segmentedControl      : UISegmentedControl!
    @IBOutlet var underlineView         : UIView!
    
    @IBOutlet var addContactButton      : UIButton!
    @IBOutlet var textLabel             : UILabel!
    
    @IBOutlet var underlineWidthConstraint              : NSLayoutConstraint!
    @IBOutlet var underlineLeftOffsetConstraint         : NSLayoutConstraint!
    
    var user = UserMyself()
    
    var listMode = WhiteBlackListsMode.whiteList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSegmentedControl()
        self.segmentedControl.sendActions(for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController!.navigationBar.hideBorderLine()
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addContactButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        let selectedIndex = self.segmentedControl.selectedSegmentIndex
        
        switch selectedIndex {
        case WhiteBlackListsMode.whiteList.rawValue:
            self.listMode = WhiteBlackListsMode.whiteList
            break
        case WhiteBlackListsMode.blackList.rawValue:
            self.listMode = WhiteBlackListsMode.blackList
            break
        default:
            break
        }
        
        self.setupUnderlineView(listMode: self.listMode)
        self.setupLabelText(listMode: self.listMode)
        self.setupAddContactButton(listMode: self.listMode)
    }
    
    func setupSegmentedControl() {
        
        self.segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: k_latoRegularFontName, size: 14)!,
            NSAttributedString.Key.foregroundColor: k_sideMenuTextFadeColor
            ], for: .normal)
        
        self.segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: k_latoBoldFontName, size: 14)!,
            NSAttributedString.Key.foregroundColor: k_redColor
            ], for: .selected)
        
    }
    
    func setupUnderlineView(listMode: WhiteBlackListsMode) {
       
        let width = self.view.frame.width / 2.0
        self.underlineWidthConstraint.constant = width
        
        switch listMode {
        case WhiteBlackListsMode.whiteList:
            self.underlineLeftOffsetConstraint.constant = 0.0
            break
        case WhiteBlackListsMode.blackList:
            self.underlineLeftOffsetConstraint.constant = width
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
        
        self.textLabel.attributedText = attributedString
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
        
        self.addContactButton .setTitle(text, for: .normal)
    }
}

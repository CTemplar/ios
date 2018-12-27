//
//  WhiteBlackListsViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class WhiteBlackListsViewController: UIViewController {
    
    @IBOutlet var segmentedControl      : UISegmentedControl!
    
    @IBOutlet var tableView             : UITableView!
    
    @IBOutlet var underlineView         : UIView!
    
    @IBOutlet var underlineWidthConstraint              : NSLayoutConstraint!
    @IBOutlet var underlineLeftOffsetConstraint         : NSLayoutConstraint!
    
    var user = UserMyself()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSegmentedControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController!.navigationBar.hideBorderLine()
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        let selectedIndex = self.segmentedControl.selectedSegmentIndex
        
        var selected = false
        
        if selectedIndex == 0 {
            selected = true
        } else {
            selected = false
        }
        
        self.setupUnderlineView(leftButtonSelected: selected)
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
        
        
        self.setupUnderlineView(leftButtonSelected: true)
    }
    
    func setupUnderlineView(leftButtonSelected: Bool) {
       
        let width = self.view.frame.width / 2.0
        self.underlineWidthConstraint.constant = width
        
        if leftButtonSelected {
            self.underlineLeftOffsetConstraint.constant = 0.0
        } else {
            self.underlineLeftOffsetConstraint.constant = width
        }
    }
}

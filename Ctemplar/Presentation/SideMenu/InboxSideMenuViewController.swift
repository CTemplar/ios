//
//  InboxSideMenuViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 12.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import AlertHelperKit //temp

class InboxSideMenuViewController: UIViewController {
    
    var presenter   : InboxSideMenuPresenter?
    var router      : InboxSideMenuRouter?
    var dataSource  : InboxSideMenuDataSource?
    
    //var optionsNameList: Array<String> = ["Logout"]
    var optionsNameList: Array<String> = [InboxSideMenuOptionsName.inbox.rawValue, InboxSideMenuOptionsName.logout.rawValue]
    
    @IBOutlet var inboxSideMenuTableView        : UITableView!
    
    @IBOutlet var emailLabel : UILabel!
    @IBOutlet var triangle   : UIImageView!
    
    @IBOutlet var triangleTrailingConstraint : NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let configurator = InboxSideMenuConfigurator()
        configurator.configure(viewController: self)
        
        dataSource?.initWith(parent: self, tableView: inboxSideMenuTableView, array: optionsNameList) 
        
        //self.view.backgroundColor = k_sideMenuColor
        
        self.navigationController?.navigationBar.isHidden = true
        
        //emailLabel.text = "xx@xx.com"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUserProfileBar()
    }
    
    func setupUserProfileBar() {
        
        let emailTextWidth = emailLabel.text?.widthOfString(usingFont: emailLabel.font)
        
        let triangleTrailingConstraintWidth = self.view.frame.width - emailTextWidth! - CGFloat(k_triangleOffset)
        updateTriangleTrailingConstraint(value: triangleTrailingConstraintWidth )
    }
    
    func updateTriangleTrailingConstraint(value: CGFloat) {
        
        DispatchQueue.main.async {
            self.triangleTrailingConstraint.constant = value
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func userProfilePressed(_ sender: AnyObject) {
        

    }    
}

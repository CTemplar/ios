//
//  ComposeViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 12.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit
import Foundation
import PKHUD
import AlertHelperKit

class ComposeViewController: UIViewController {
    
    var presenter   : ComposePresenter?
    var router      : ComposeRouter?
    var dataSource  : ComposeDataSource?
    
    var navBarTitle: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let configurator = ComposeConfigurator()
        configurator.configure(viewController: self)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.title = navBarTitle
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        
        //sendMail() //temp
        //publicKeyFor(userEmail: "dmitry5@dev.ctemplar.com")
    }
}

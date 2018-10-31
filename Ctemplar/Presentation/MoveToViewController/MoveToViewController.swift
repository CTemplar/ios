//
//  MoveToViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 31.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class MoveToViewController: UIViewController {
    
    //var presenter   : InboxPresenter?
    //var router      : InboxRouter?
    //var dataSource  : InboxDataSource?
    
    @IBOutlet var cancelButton          : UIButton!
    @IBOutlet var applyButton           : UIButton!

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func manageFoldersButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func applyButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

//
//  MoveToViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 31.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Networking

class MoveToViewController: UIViewController {
    
    var presenter   : MoveToPresenter?
    var router      : MoveToRouter?
    var dataSource  : MoveToDataSource?
    
    @IBOutlet var cancelButton          : UIButton!
    @IBOutlet var applyButton           : UIButton!
    
    @IBOutlet var addFolderButton       : UIButton!
    @IBOutlet var manageFolderButton    : UIButton!
    @IBOutlet var manageFolderView      : UIView!
    
    @IBOutlet var addFolderLabel        : UILabel!
    @IBOutlet var addFolderImage        : UIImageView!
    
    @IBOutlet var moveToTableView       : UITableView!
    
    var selectedMessagesIDArray : Array<Int> = []
    
    var delegate: MoveToViewControllerDelegate?
    
    var user = UserMyself()

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = MoveToConfigurator()
        configurator.configure(viewController: self)
        
        dataSource?.initWith(parent: self, tableView: moveToTableView)
        
        self.presenter?.applyButton(enabled: false)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.presenter?.interactor?.customFoldersList()
    }
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        
        self.router?.showAddFolderViewController()
    }
    
    @IBAction func manageFoldersButtonPressed(_ sender: AnyObject) {
        
        self.router?.showFoldersManagerViewController()
    }
    
    @IBAction func applyButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.interactor?.applyButtonPressed()
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

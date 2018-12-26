//
//  SetMailboxViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 26.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import AlertHelperKit
import PKHUD

class SetMailboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet var leftBarButtonItem       : UIBarButtonItem!

    @IBOutlet var tableView               : UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var apiService      : APIService?
    
    var user = UserMyself()
    var mailboxesArray          : Array<Mailbox> = []
    
    var formatterService        : FormatterService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mailboxesArray = self.user.mailboxesList!
        
        self.formatterService = appDelegate.applicationManager.formatterService
        self.apiService = appDelegate.applicationManager.apiService
       
        self.registerTableViewCell() 
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        self.tableView.register(UINib(nibName: k_UserMailboxCellXibName, bundle: nil), forCellReuseIdentifier: k_UserMailboxTableViewCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mailboxesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: k_UserMailboxTableViewCellIdentifier)! as! UserMailboxTableViewCell
        
        let mailbox = self.mailboxesArray[indexPath.row]
        
        if let email = mailbox.email {
            cell.emailLabel.text = email
        }
        
        return cell
    }
}

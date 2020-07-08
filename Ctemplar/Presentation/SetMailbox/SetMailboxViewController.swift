//
//  SetMailboxViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 26.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility
import Networking

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
        
        self.formatterService = UtilityManager.shared.formatterService
        self.apiService = NetworkManager.shared.apiService
       
        self.tableView.tableFooterView = UIView()
        
        self.registerTableViewCell() 
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        self.tableView.register(UINib(nibName: k_UserMailboxBigCellXibName, bundle: nil), forCellReuseIdentifier: k_UserMailboxBigTableViewCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mailboxesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: k_UserMailboxBigTableViewCellIdentifier)! as! UserMailboxBigTableViewCell
        
        let mailbox = self.mailboxesArray[indexPath.row]
        
        var selected = false
        
        if mailbox.isDefault! {
            selected = true
        }
        
        if let email = mailbox.email {
            cell.setupCellWithData(email: email, seleted: selected)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.mailboxesArray.count > 1 {
        
            let mailbox = self.mailboxesArray[indexPath.row]
        
            self.setDefaultMailbox(mailbox: mailbox)
        }
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
    }
    
    //MARK: - API
    
    func setDefaultMailbox(mailbox: Mailbox) {
        let mailboxID = mailbox.mailboxID?.description
        let isDefault = true
        
        Loader.start()
        
        apiService?.updateMailbox(mailboxID: mailboxID!, userSignature: "", displayName: "", isDefault: isDefault) { [weak self] (result) in
            switch(result) {
            case .success(let value):
                print("setDefaultMailbox value:", value)
                self?.userMyself()
            case .failure(let error):
                print("error:", error)
                self?.showAlert(with: "Update Settings Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
            }
            
            Loader.stop()
        }
    }
    
    func userMyself() {
        Loader.start()
        apiService?.userMyself() { [weak self] (result) in
            switch(result) {
            case .success(let value):
                let userMyself = value as! UserMyself
                if let mailboxes = userMyself.mailboxesList {
                    self?.mailboxesArray = mailboxes
                }
                self?.reloadData()
                self?.postUpdateUserSettingsNotification()
            case .failure(let error):
                print("error:", error)
                self?.showAlert(with: "User Myself Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
            }
            Loader.stop()
        }
    }
    
    func postUpdateUserSettingsNotification() {
        NotificationCenter.default.post(name: .updateUserSettingsNotificationID, object: nil, userInfo: nil)
    }
}

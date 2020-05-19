//
//  PgpKeysDataSource.swift
//  Ctemplar
//
//  Created by Majid Hussain on 08/03/2020.
//  Copyright © 2020 CTemplar. All rights reserved.
//

import UIKit

class PgpKeysDatasource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var viewController: PgpKeysViewController!
    
    func initWith(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewController.mailboxList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath)
        cell.textLabel?.text = viewController.mailboxList[indexPath.row].email ?? ""
        cell.textLabel?.font = k_readMessageSubjectFont
        cell.textLabel?.textColor = k_fingerprintTextColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewController.presenter?.setValues(for: self.viewController.mailboxList[indexPath.row])
        self.viewController.presenter?.tableViewSelectionComplete()
    }
}

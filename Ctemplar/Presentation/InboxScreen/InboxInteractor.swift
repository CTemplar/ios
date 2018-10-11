//
//  InboxInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit

class InboxInteractor {
    
    var viewController  : InboxViewController?
    var presenter       : InboxPresenter?
    var apiService      : APIService?

    func setInboxData(array: Array<EmailMessageResult>) {
        
        self.viewController?.messagesList = array
        self.viewController?.dataSource?.messagesArray = array
        self.viewController?.dataSource?.tableView.reloadData()//temp
        
        self.viewController?.setupUI()
    }
    
    func messagesList() {
        
        apiService?.messagesList() {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                var messagesArray : Array<EmailMessageResult> = []
                
                let emailMessage = value as! EmailMessage
                
                for result in emailMessage.messageResultsList! {
                    //print("result", result)
                    messagesArray.append(result)
                }
                
                self.setInboxData(array: messagesArray)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "Close")
            }
        }
    }
}

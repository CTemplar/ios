//
//  ViewInboxEmailInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class ViewInboxEmailInteractor {
    
    var viewController      : ViewInboxEmailViewController?
    var presenter           : ViewInboxEmailPresenter?
    var apiService          : APIService?
    var pgpService          : PGPService?
    var formatterService    : FormatterService?
    

    func setMessageData(messages: EmailMessagesList) {
        
        if let emailsArray = messages.messagesList {
            if emailsArray.count > 0 {
                if let message = emailsArray.first {
                    self.viewController?.message = message
                    self.viewController?.messageIsRead = message.read
                    self.viewController?.messageIsStarred = message.starred
                    
                    if (message.children?.count)! > 0 {
                        self.viewController?.messagesTableView.isHidden = false
                        self.viewController?.dataSource?.messagesArray = message.children!
                        self.viewController?.dataSource?.messagesArray.insert(message, at: 0) //add parent Message
                        self.viewController?.dataSource?.reloadData()
                    } else {
                        self.presenter?.setupMessageContent(message: message)
                    }
                    
                    self.presenter?.setupMessageHeader(message: message)
                    self.presenter?.setupNavigationBar(enabled: true)
                    self.presenter?.setupBottomBar(enabled: true)
                }
            }
        }
    }
    
    func getMessage(messageID: Int) {
        
        HUD.show(.progress)
        
        apiService?.messagesList(folder: "", messagesIDIn: messageID.description, seconds: 0) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
  
                let emailMessages = value as! EmailMessagesList
                self.setMessageData(messages: emailMessages)
                                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
    
    func extractMessageContent(message: EmailMessage) -> String {
        
        if let content = message.content {            
            if let message = self.pgpService?.decryptMessage(encryptedContet: content) {
                print("decrypt viewed message: ", message)
                return message
            }
        }
        
        return "Error"
    }
    
    func headerOfMessage(content: String) -> String {
        
        var header : String = ""
        var message : String = ""
        
        message = content
        message = message.removeHTMLTag
        
        if message.count > 0 {
            
            if message.count > k_firstCharsForHeader {
                let index = message.index(message.startIndex, offsetBy: k_firstCharsForHeader)
                header = String(message.prefix(upTo: index))
            } else {
                header = message
            }
        }
        
        header = header.replacingOccurrences(of: "\\s", with: " ", options: String.CompareOptions.regularExpression)
        
        return header
    }
    
    func moveMessageToTrash(message: EmailMessage, withUndo: String) {
        
        self.viewController?.lastAction = ActionsIndex.moveToTrach
        
        var folder = message.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.trash.rawValue
        }
        
        self.moveMessageTo(message: message, folder: folder!, withUndo: withUndo)
    }
    
    func moveMessageToSpam(message: EmailMessage, withUndo: String) {
        
        self.viewController?.lastAction = ActionsIndex.markAsSpam
        
        var folder = message.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.spam.rawValue
        }
        
        self.moveMessageTo(message: message, folder: folder!, withUndo: withUndo)
    }
    
    func moveMessageToInbox(message: EmailMessage, withUndo: String) {
        
        self.viewController?.lastAction = ActionsIndex.moveToInbox
        
        var folder = message.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.inbox.rawValue
        }
        
        self.moveMessageTo(message: message, folder: folder!, withUndo: withUndo)
    }
    
    func moveMessageToArchive(message: EmailMessage, withUndo: String) {
        
        self.viewController?.lastAction = ActionsIndex.moveToArchive
        
        var folder = message.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.archive.rawValue
        }
        
        self.moveMessageTo(message: message, folder: folder!, withUndo: withUndo)
    }
/*
    func markMessageAsStarred(message: EmailMessage, starred: Bool, withUndo: String) {
     
        self.viewController?.lastAction = ActionsIndex.markAsStarred
        
    }*/
    
    func moveMessageTo(message: EmailMessage, folder: String, withUndo: String) {
        
        apiService?.updateMessages(messageID: (message.messsageID?.description)!, messagesIDIn: "", folder: folder, starred: false, read: false, updateFolder: true, updateStarred: false, updateRead: false)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("move message to:", folder)
                
                if withUndo.count > 0 {
                    self.presenter?.showUndoBar(text: withUndo)
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func markMessageAsRead(message: EmailMessage, asRead: Bool, withUndo: String) {
        
        self.viewController?.lastAction = ActionsIndex.markAsRead
        
        apiService?.updateMessages(messageID: message.messsageID!.description, messagesIDIn: "", folder: message.folder!, starred: false, read: asRead, updateFolder: false, updateStarred: false, updateRead: true)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("mark message as read:", asRead)
                
                self.viewController?.messageIsRead = asRead
                
                if withUndo.count > 0 {
                    self.presenter?.showUndoBar(text: withUndo)
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func markMessageAsStarred(message: EmailMessage, starred: Bool, withUndo: String) {
        
        //self.viewController?.lastAction = ActionsIndex.markAsStarred
        
        apiService?.updateMessages(messageID: message.messsageID!.description, messagesIDIn: "", folder: message.folder!, starred: starred, read: false, updateFolder: false, updateStarred: true, updateRead: false)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("mark message as starred:", starred)
                
                self.viewController?.messageIsStarred = starred
                
                self.presenter?.setupStarredButton(starred: starred)
                
                /*
                if withUndo.count > 0 {
                    self.presenter?.showUndoBar(text: withUndo)
                }*/
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func undoLastAction(message: EmailMessage) {
        
        self.presenter?.hideUndoBar()
        
        print("undo pressed")
        
        switch self.viewController?.lastAction.rawValue {
        case ActionsIndex.markAsSpam.rawValue:
            self.moveMessageToSpam(message: message, withUndo: "")
            break
        case ActionsIndex.markAsRead.rawValue:
            self.markMessageAsRead(message: message, asRead: message.read!, withUndo: "")
            break
        case ActionsIndex.markAsStarred.rawValue:
            self.markMessageAsStarred(message: message, starred: message.starred!, withUndo: "")
            break
        case ActionsIndex.moveToArchive.rawValue:
            self.moveMessageToArchive(message: message, withUndo: "")
            break
        case ActionsIndex.moveToTrach.rawValue:
            self.moveMessageToTrash(message: message, withUndo: "")
            break
        case ActionsIndex.moveToInbox.rawValue:
            self.moveMessageToInbox(message: message, withUndo: "")
            break
        default:
            print("unknown undo action")
        }
    }
}

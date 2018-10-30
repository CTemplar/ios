//
//  InboxDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import MGSwipeTableCell

class InboxDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {
    
    var messagesArray           : Array<EmailMessage> = []
    var messagesHeaderArray     : Array<String> = []
    var selectedMessagesIDArray : Array<Int> = []
    
    var tableView               : UITableView!
    var parentViewController    : InboxViewController!
    var formatterService        : FormatterService?
    
    var selectionMode : Bool = false
    
    func initWith(parent: InboxViewController, tableView: UITableView, array: Array<EmailMessage>) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.messagesArray = array

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        self.tableView.addGestureRecognizer(longPressRecognizer)
        
        registerTableViewCell()
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
       self.tableView.register(UINib(nibName: k_InboxMessageTableViewCellXibName, bundle: nil), forCellReuseIdentifier: k_InboxMessageTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : InboxMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: k_InboxMessageTableViewCellIdentifier)! as! InboxMessageTableViewCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        let trashButton = MGSwipeButton(title: "", icon: UIImage(named: k_whiteGarbageImageName), backgroundColor: k_sideMenuColor)
        let unreadButton = MGSwipeButton(title: "", icon: UIImage(named: k_witeUnreadImageName), backgroundColor: k_sideMenuColor)
        let spamButton = MGSwipeButton(title: "", icon: UIImage(named: k_whiteSpamImageName), backgroundColor: k_sideMenuColor)
        
        cell.rightButtons = [spamButton, unreadButton, trashButton]
        cell.delegate = self
        
        cell.parentController = self
        
        let message = messagesArray[indexPath.row]
        let selected = isMessageSelected(message: message)
        let header = messagesHeaderArray[indexPath.row]
        
        cell.setupCellWithData(message: message, header: header, isSelectionMode: self.selectionMode, isSelected: selected, frameWidth: self.tableView.frame.width)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.selectionMode == false {
            self.parentViewController.router?.showViewInboxEmailViewController()
        } else {
            let message = messagesArray[indexPath.row]
            let selected = isMessageSelected(message: message)
            
            if selected {
                if let index = selectedMessagesIDArray.index(where: {$0 == message.messsageID}) {
                    print("deselected")
                   selectedMessagesIDArray.remove(at: index)
                }
            } else {
                print("selected")
                selectedMessagesIDArray.append(message.messsageID!)
            }
            
            self.reloadData()
            
            self.parentViewController.presenter?.setupNavigationItemTitle(selectedMessages: selectedMessagesIDArray.count, selectionMode: selectionMode, currentFolder: self.parentViewController!.currentFolder)
        }
    }
    
    func reloadData() {

        self.tableView.reloadData()
    }
    
    // MARK: MGSwipe delegate
    
    func swipeTableCell(_ cell: MGSwipeTableCell, didChange state: MGSwipeState, gestureIsActive: Bool) {
        
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        
        if self.selectionMode {
            return false
        }
        
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return true }
        
        let message = messagesArray[indexPath.row]
        self.parentViewController.appliedActionMessage = message
        
        switch index {
        case InboxCellButtonsIndex.trash.rawValue:
            print("trash tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsTrash(message: message)
            break
        case InboxCellButtonsIndex.unread.rawValue:
            print("unread tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsRead(message: message)
            break
        case InboxCellButtonsIndex.spam.rawValue:
            print("spam tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsSpam(message: message)            
            break
        default:
            print("default")
        }
        
        return true
    }
    
    // MARK: Actions
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                print("Long pressed row: \(indexPath.row)")
                if self.selectionMode == false {
                    self.parentViewController.presenter?.enableSelectionMode()
                }
            }
        }
    }
    
    // MARK: local methods
    
    func isMessageSelected(message: EmailMessage) -> Bool {
        
        for resultID in selectedMessagesIDArray {
            if resultID == message.messsageID {
                return true
            }
        }
        
        return false
    }
}

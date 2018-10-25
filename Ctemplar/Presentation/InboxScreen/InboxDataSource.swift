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
        
        cell.rightButtons = [MGSwipeButton(title: "Spam", backgroundColor: .red), MGSwipeButton(title: "Read", backgroundColor: .green),MGSwipeButton(title: "Trash", backgroundColor: .gray)]
        cell.delegate = self
        
        cell.parentController = self
        
        let message = messagesArray[indexPath.row]
        let selected = isMessageSelected(message: message)
        
        cell.setupCellWithData(message: message, isSelectionMode: self.selectionMode, isSelected: selected, frameWidth: self.tableView.frame.width)
        
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
                if let index = selectedMessagesIDArray.index(where: {$0 == message.resultID}) {
                    print("deselected")
                   selectedMessagesIDArray.remove(at: index)
                }
            } else {
                print("selected")
                selectedMessagesIDArray.append(message.resultID!)
            }
            
            self.reloadData()
        }
    }
    
    func reloadData() {

        self.tableView.reloadData()
    }
    
    // MARK: MGSwipe delegate
    
    func swipeTableCell(_ cell: MGSwipeTableCell, didChange state: MGSwipeState, gestureIsActive: Bool) {
        
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        
        switch index {
        case InboxCellButtonsIndex.spam.rawValue:
            print("spam tapped")
            break
        case InboxCellButtonsIndex.read.rawValue:
            print("read tapped")
            break
        case InboxCellButtonsIndex.trash.rawValue:
            print("trash tapped")
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
            if resultID == message.resultID {
                return true
            }
        }
        
        return false
    }
}

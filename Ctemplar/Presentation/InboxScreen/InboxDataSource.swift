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
    
    func setupSwipeActionsButton() -> Array<MGSwipeButton> {
        
        var swipeButtonsArray : Array<MGSwipeButton> = []
        
        let trashButton = MGSwipeButton(title: "", icon: UIImage(named: k_whiteGarbageImageName), backgroundColor: k_sideMenuColor)
        let unreadButton = MGSwipeButton(title: "", icon: UIImage(named: k_witeUnreadImageName), backgroundColor: k_sideMenuColor)
        let spamButton = MGSwipeButton(title: "", icon: UIImage(named: k_whiteSpamImageName), backgroundColor: k_sideMenuColor)
        let moveToButton = MGSwipeButton(title: "", icon: UIImage(named: k_witeMoveToImageName), backgroundColor: k_sideMenuColor)
        
        let currentFolder = self.parentViewController.currentFolderFilter
        
        switch currentFolder {
        case MessagesFoldersName.inbox.rawValue:
            swipeButtonsArray = [trashButton, moveToButton, spamButton]
            break
        case MessagesFoldersName.draft.rawValue:
            swipeButtonsArray = [trashButton]
            break
        case MessagesFoldersName.sent.rawValue:
            swipeButtonsArray = [trashButton, moveToButton, spamButton] //? spam?
            break
        case MessagesFoldersName.outbox.rawValue:
            swipeButtonsArray = [trashButton, moveToButton, spamButton] //?
            break
        case MessagesFoldersName.starred.rawValue:
            swipeButtonsArray = [trashButton, moveToButton, spamButton]
            break
        case MessagesFoldersName.archive.rawValue:
            swipeButtonsArray = [trashButton, moveToButton, spamButton]
            break
        case MessagesFoldersName.spam.rawValue:
            swipeButtonsArray = [trashButton, moveToButton, unreadButton]
            break
        case MessagesFoldersName.trash.rawValue:
            swipeButtonsArray = [trashButton, moveToButton, spamButton] //? trash?
            break
        default:
            break
        }
        
        return swipeButtonsArray
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

        cell.rightButtons = self.setupSwipeActionsButton()
        cell.delegate = self
        
        cell.parentController = self
        
        let message = messagesArray[indexPath.row]
        let selected = isMessageSelected(message: message)
        
        var localHeader = ""
        
        if messagesHeaderArray.count > indexPath.row {
            localHeader = messagesHeaderArray[indexPath.row]
        }

        cell.setupCellWithData(message: message, header: localHeader, isSelectionMode: self.selectionMode, isSelected: selected, frameWidth: self.tableView.frame.width)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let message = messagesArray[indexPath.row]
         
        if self.selectionMode == false {
            self.parentViewController.router?.showViewInboxEmailViewController(message: message)
        } else {
            
            let selected = isMessageSelected(message: message)
            
            if selected {
                if let index = selectedMessagesIDArray.index(where: {$0 == message.messsageID}) {
                    print("deselected")
                   selectedMessagesIDArray.remove(at: index)
                }
            } else {
                print("selected")
                selectedMessagesIDArray.append(message.messsageID!)
                self.parentViewController.appliedActionMessage = message
            }
            
            if selectedMessagesIDArray.count == 0 {
                self.parentViewController.presenter?.disableSelectionMode()
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
        
        selectedMessagesIDArray.removeAll()
        selectedMessagesIDArray.append(message.messsageID!)
        
        let currentFolder = self.parentViewController.currentFolderFilter
        
        switch currentFolder {
        case MessagesFoldersName.inbox.rawValue:
            self.inboxSwipeAction(index: index, message: message)
            break
        case MessagesFoldersName.draft.rawValue:
            self.draftSwipeAction(index: index, message: message)
            break
        case MessagesFoldersName.sent.rawValue:
            self.sentSwipeAction(index: index, message: message)
            break
        case MessagesFoldersName.outbox.rawValue:
            self.outboxSwipeAction(index: index, message: message)
            break
        case MessagesFoldersName.starred.rawValue:
            self.starredSwipeAction(index: index, message: message)
            break
        case MessagesFoldersName.archive.rawValue:
            self.archiveSwipeAction(index: index, message: message)
            break
        case MessagesFoldersName.spam.rawValue:
            self.spamSwipeAction(index: index, message: message)
            break
        case MessagesFoldersName.trash.rawValue:
            self.trashSwipeAction(index: index, message: message)
            break
        default:
            break
        }

        return true
    }
    
    // MARK: Swipe Actions
  
    func inboxSwipeAction(index: Int, message: EmailMessage) {
        
        switch index {
        case InboxCellButtonsIndex.right.rawValue:
            print("trash tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsTrash(message: message)
            break
        case InboxCellButtonsIndex.middle.rawValue:
            print("move to tapped")
            self.parentViewController.presenter?.interactor?.showMoveTo(message: message)
            break
        case InboxCellButtonsIndex.left.rawValue:
            print("spam tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsSpam(message: message)
            break
        default:
            break
        }
    }
    
    func draftSwipeAction(index: Int, message: EmailMessage) {
        
        switch index {
        case InboxCellButtonsIndex.right.rawValue:
            print("trash tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsTrash(message: message)
            break
        case InboxCellButtonsIndex.middle.rawValue:
            //print("move to tapped")
            //self.parentViewController.presenter?.interactor?.markMessageAsRead(message: message)
            break
        case InboxCellButtonsIndex.left.rawValue:
            //print("spam tapped")
            //self.parentViewController.presenter?.interactor?.markMessageAsSpam(message: message)
            break
        default:
            break
        }
    }
    
    func sentSwipeAction(index: Int, message: EmailMessage) {
        
        switch index {
        case InboxCellButtonsIndex.right.rawValue:
            print("trash tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsTrash(message: message)
            break
        case InboxCellButtonsIndex.middle.rawValue:
            print("move to tapped")
            self.parentViewController.presenter?.interactor?.showMoveTo(message: message)
            break
        case InboxCellButtonsIndex.left.rawValue:
            print("spam tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsSpam(message: message)
            break
        default:
            break
        }
    }
    
    func outboxSwipeAction(index: Int, message: EmailMessage) {
        
        switch index {
        case InboxCellButtonsIndex.right.rawValue:
            print("trash tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsTrash(message: message)
            break
        case InboxCellButtonsIndex.middle.rawValue:
            print("move to tapped")
            self.parentViewController.presenter?.interactor?.showMoveTo(message: message)
            break
        case InboxCellButtonsIndex.left.rawValue:
            print("spam tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsSpam(message: message)
            break
        default:
            break
        }
    }
    
    func starredSwipeAction(index: Int, message: EmailMessage) {
        
        switch index {
        case InboxCellButtonsIndex.right.rawValue:
            print("trash tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsTrash(message: message)
            break
        case InboxCellButtonsIndex.middle.rawValue:
            print("move to tapped")
            self.parentViewController.presenter?.interactor?.showMoveTo(message: message)
            break
        case InboxCellButtonsIndex.left.rawValue:
            print("spam tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsSpam(message: message)
            break
        default:
            break
        }
    }
    
    func archiveSwipeAction(index: Int, message: EmailMessage) {
        
        switch index {
        case InboxCellButtonsIndex.right.rawValue:
            print("trash tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsTrash(message: message)
            break
        case InboxCellButtonsIndex.middle.rawValue:
            print("move to tapped")
            self.parentViewController.presenter?.interactor?.showMoveTo(message: message)
            break
        case InboxCellButtonsIndex.left.rawValue:
            print("spam tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsSpam(message: message)
            break
        default:
            break
        }
    }
    
    func spamSwipeAction(index: Int, message: EmailMessage) {
        
        switch index {
        case InboxCellButtonsIndex.right.rawValue:
            print("trash tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsTrash(message: message)
            break
        case InboxCellButtonsIndex.middle.rawValue:
            print("move to tapped")
            self.parentViewController.presenter?.interactor?.showMoveTo(message: message)
            break
        case InboxCellButtonsIndex.left.rawValue:
            print("read tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsRead(message: message)
            break
        default:
            break
        }
    }
    
    func trashSwipeAction(index: Int, message: EmailMessage) {
        
        switch index {
        case InboxCellButtonsIndex.right.rawValue:
            print("trash tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsTrash(message: message)
            break
        case InboxCellButtonsIndex.middle.rawValue:
            print("move to tapped")
            self.parentViewController.presenter?.interactor?.showMoveTo(message: message)
            break
        case InboxCellButtonsIndex.left.rawValue:
            print("spam tapped")
            self.parentViewController.presenter?.interactor?.markMessageAsSpam(message: message)
            break
        default:
            break
        }
    }
    
    // MARK: Actions
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                let message = messagesArray[indexPath.row]
                
                print("Long pressed row: \(indexPath.row)")
                if self.selectionMode == false {
                    self.parentViewController.presenter?.enableSelectionMode()
                    self.selectedMessagesIDArray.append(message.messsageID!)
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

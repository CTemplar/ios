//
//  InboxPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD
import SideMenu

class InboxPresenter {
    
    var viewController   : InboxViewController?
    var interactor       : InboxInteractor?
    
    var timer = Timer()
    var counter = 0
    
    //MARK: - API Requests
    /*
    func loadMessages(folder: String) {
        
        self.interactor?.messagesList(folder: folder, withUndo: "", silent: false)
    }*/
    
    //MARK: - setup UI
    
    func setupUI(emailsCount: Int, unreadEmails: Int, filterEnabled: Bool) {
        
        if filterEnabled {
            viewController?.messagesLabel.text = "Filtered"
            viewController?.unreadMessagesLabel.text = self.formatAppliedFilters()
            viewController?.unreadMessagesLabel.textColor = k_redColor
            
            viewController?.inboxEmptyLabel.text = "There are no messages match the filter"
            viewController?.inboxEmptyImageView.image =  UIImage(named: k_emptyFilterInboxIconImageName)
        } else {
            viewController?.messagesLabel.text = formatEmailsCountText(emailsCount: emailsCount)
            viewController?.unreadMessagesLabel.text = formatUreadEmailsCountText(emailsCount: unreadEmails)
            viewController?.unreadMessagesLabel.textColor = k_lightGrayTextColor
            
            viewController?.inboxEmptyLabel.text = "You have no Inbox messages"
            viewController?.inboxEmptyImageView.image =  UIImage(named: k_emptyInboxIconImageName)
        }
        
        var moreButtonEnabled: Bool = false
        
        if emailsCount > 0 {
            //viewController?.emptyInbox.isHidden = true
            viewController?.advancedToolBar.isHidden = false
            moreButtonEnabled = true
        } else {
            //viewController?.emptyInbox.isHidden = false
            viewController?.advancedToolBar.isHidden = true
        }
        
        var composeImage: UIImage?
        
        if Device.IS_IPHONE_X_OR_ABOVE {
            viewController?.grayBorder.isHidden = true
            composeImage = UIImage.init(named: k_composeRedImageName)
            viewController?.rightComposeButton.backgroundColor = UIColor.white
        } else {
            viewController?.grayBorder.isHidden = false
            composeImage = UIImage.init(named: k_composeImageName)
            viewController?.rightComposeButton.backgroundColor = k_redColor
        }
        
        viewController?.rightComposeButton.setImage(composeImage, for: .normal)
        
        viewController?.undoBar.isHidden = true
        //viewController?.undoBar.blur(blurRadius: 5)
        
        setupNavigationItemTitle(selectedMessages: (self.viewController?.dataSource?.selectedMessagesIDArray.count)!, selectionMode: (self.viewController?.dataSource?.selectionMode)!, currentFolder: self.viewController!.currentFolder)
        
        setupNavigationRightItems(searchMode: false, moreButtonEnabled: moreButtonEnabled)
        
        if (self.viewController?.dataSource?.messagesArray.count)! > 0 {
            viewController?.emptyInbox.isHidden = true
        } else {
            viewController?.emptyInbox.isHidden = false
       }
    }
    
    func setupNavigationItemTitle(selectedMessages: Int, selectionMode: Bool, currentFolder: String) {
        
        if selectionMode == true {
            self.viewController?.navigationItem.title = String(format: "%d Selected", selectedMessages)
        } else {
            self.viewController?.navigationItem.title = currentFolder
        }
    }
    
    func setupNavigationRightItems(searchMode: Bool, moreButtonEnabled: Bool) {
        
        let searchButton : UIButton = UIButton.init(type: .custom)
        searchButton.setImage(UIImage(named: k_searchImageName), for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonPresed), for: .touchUpInside)
        searchButton.frame = CGRect(x: 0, y: 0, width: k_navBarButtonSize, height: k_navBarButtonSize)
        let searchItem = UIBarButtonItem(customView: searchButton)
        
        let moreButton : UIButton = UIButton.init(type: .custom)
        moreButton.setImage(UIImage(named: k_moreImageName), for: .normal)
        moreButton.addTarget(self, action: #selector(moreButtonPresed), for: .touchUpInside)
        moreButton.frame = CGRect(x: 0, y: 0, width: k_navBarButtonSize, height: k_navBarButtonSize)
        let moreItem = UIBarButtonItem(customView: moreButton)
        
        moreItem.isEnabled = moreButtonEnabled
        
        let cancelItem = UIBarButtonItem(title: "cancelButton".localized(), style: .plain, target: self, action: #selector(cancelButtonPresed))
        cancelItem.tintColor = UIColor.darkGray
        
        if searchMode {
            self.viewController?.navigationItem.rightBarButtonItems = [cancelItem]
        } else {
            if self.viewController?.currentFolderFilter ==  MessagesFoldersName.spam.rawValue || self.viewController?.currentFolderFilter ==  MessagesFoldersName.trash.rawValue{
                self.viewController?.navigationItem.rightBarButtonItems = [searchItem, moreItem]
            } else {
                self.viewController?.navigationItem.rightBarButtonItems = [searchItem]
            }
        }
    }
    
    //MARK: - Side Menu
    
    func initAndSetupInboxSideMenuController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxSideMenuStoryboardName, bundle: nil)
       
        self.viewController?.inboxSideMenuViewController = storyboard.instantiateViewController(withIdentifier: k_InboxSideMenuViewControllerID) as? InboxSideMenuViewController
        
        self.viewController?.inboxSideMenuViewController?.currentParentViewController = self.viewController
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: (self.viewController?.inboxSideMenuViewController)!)
        
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuAnimationFadeStrength = 0.5
        SideMenuManager.default.menuAnimationBackgroundColor = k_sideMenuFadeColor
        
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        let frame = self.viewController?.view.frame
        SideMenuManager.default.menuWidth = max(round(min((frame!.width), (frame!.height)) * 0.67), 240)
    }
        
    //MARK: - formatting
    
    func formatEmailsCountText(emailsCount: Int) -> String {
        
        var emailsCountString : String = "emails"
        
        if emailsCount == 1 {
            emailsCountString = "email"
        }
        
        emailsCountString = emailsCount.description + " " + emailsCountString
        
        return emailsCountString
    }
    
    func formatUreadEmailsCountText(emailsCount: Int) -> String {
        
        var emailsCountString : String = "unread"
        
        emailsCountString = emailsCount.description + " " + emailsCountString
        
        return emailsCountString
    }
    
    //MARK: - navigation bar
    
    @objc func searchButtonPresed() {
 
        self.viewController?.router?.showSearchViewController()
    }
    
    @objc func cancelButtonPresed() {
        
        disableSelectionMode()
    }
    
    @objc func moreButtonPresed() {
        
        showMoreActionsView(emptyFolder: true)
    }
    
    /*
    func searchButtonPressed(sender: AnyObject) {
        
        if self.viewController?.dataSource?.selectionMode == true {
            disableSelectionMode()
        } else {
            //self.viewController?.router?.showMoveToViewController()//temp
        }
    }*/
    
    func enableSelectionMode() {
        
        var moreButtonEnabled: Bool = false
        
        self.viewController?.dataSource?.selectionMode = true
        self.viewController?.dataSource?.reloadData()
        
        if (self.viewController?.dataSource?.messagesArray.count)! > 0 {
            moreButtonEnabled = true
        }
        
        self.viewController?.leftBarButtonItem.image = nil
        self.viewController?.leftBarButtonItem.isEnabled = false
        
        setupNavigationRightItems(searchMode: true, moreButtonEnabled: moreButtonEnabled)
        
        if self.viewController?.currentFolderFilter ==  MessagesFoldersName.draft.rawValue {
            self.viewController?.selectionDraftToolBar.isHidden = false
        } else {
            self.viewController?.selectionToolBar.isHidden = false
        }
        
        setupNavigationItemTitle(selectedMessages: (self.viewController?.dataSource?.selectedMessagesIDArray.count)!, selectionMode: (self.viewController?.dataSource?.selectionMode)!, currentFolder: self.viewController!.currentFolder)
        
        //self.viewController?.appliedActionMessage = nil
        //self.viewController?.dataSource?.selectedMessagesIDArray.removeAll()
    }
    
    func disableSelectionMode() {
        
        var moreButtonEnabled: Bool = false
        
        self.viewController?.appliedActionMessage = nil
        self.viewController?.dataSource?.selectionMode = false
        self.viewController?.dataSource?.selectedMessagesIDArray.removeAll()
        self.viewController?.dataSource?.reloadData()
        
        if (self.viewController?.dataSource?.messagesArray.count)! > 0 {
            moreButtonEnabled = true
        }
        
        self.viewController?.leftBarButtonItem.image = UIImage(named: k_menuImageName)
        self.viewController?.leftBarButtonItem.isEnabled = true
                
        setupNavigationRightItems(searchMode: false, moreButtonEnabled: moreButtonEnabled)
        
        self.viewController?.selectionDraftToolBar.isHidden = true
        self.viewController?.selectionToolBar.isHidden = true
        
        setupNavigationItemTitle(selectedMessages: (self.viewController?.dataSource?.selectedMessagesIDArray.count)!, selectionMode: (self.viewController?.dataSource?.selectionMode)!, currentFolder: self.viewController!.currentFolder)
    }
    
    //MARK: - filter
    
    func initFilterView() {
        
        self.viewController?.inboxFilterView = Bundle.main.loadNibNamed(k_InboxFilterViewXibName, owner: nil, options: nil)?.first as? InboxFilterView
        self.viewController?.inboxFilterView?.frame = CGRect(x: 0.0, y: 0.0, width: self.viewController!.view.frame.width, height: self.viewController!.view.frame.height)
        self.viewController?.inboxFilterView?.delegate = self.viewController
        self.viewController?.inboxFilterView?.setup(appliedFilters: (self.viewController?.appliedFilters)!)
        self.viewController?.navigationController!.view.addSubview((self.viewController?.inboxFilterView)!)
        
        self.viewController?.inboxFilterView?.isHidden = true
    }
    
    func showFilterView() {
        
        let hidden = self.viewController?.inboxFilterView?.isHidden
        
        self.viewController?.inboxFilterView?.isHidden = !hidden!
        
        self.viewController?.inboxFilterView?.setup(appliedFilters: (self.viewController?.appliedFilters)!)
        
        if !hidden! {
            self.viewController?.leftFilterButton.setImage(UIImage(named: k_filterImageName), for: .normal)
        } else {
            self.viewController?.leftFilterButton.setImage(UIImage(named: k_blackFilterImageName), for: .normal)
        }
    }
    
    func applyFilterAction(_ sender: AnyObject) {
        
        switch sender.tag {
            
        case InboxFilterViewButtonsTag.cancelButton.rawValue:
            print("cancel filters")
            self.viewController?.presenter?.setupUI(emailsCount: (self.viewController?.emailsCount)!, unreadEmails: (self.viewController?.unreadEmails)!, filterEnabled: false)
            break
        case InboxFilterViewButtonsTag.applyButton.rawValue:
            print("apply filters")
            self.interactor?.applyFilters()
            let filterEnabled = self.interactor?.filterEnabled()
            self.viewController?.presenter?.setupUI(emailsCount: (self.viewController?.emailsCount)!, unreadEmails: (self.viewController?.unreadEmails)!, filterEnabled: filterEnabled!)
            break
        default:
            print("filter: default")
        }
    }
    
    func formatAppliedFilters() -> String {
        
        var appliedFiltersText = "" //Starred, Unread, With attachments
        
        for (index, filterApplied) in (self.viewController?.appliedFilters)!.enumerated() {
            
            switch index + InboxFilterButtonsTag.starred.rawValue {
            case InboxFilterButtonsTag.starred.rawValue:
                //print("starred filtered")
                if filterApplied == true {
                   appliedFiltersText = "Starred"
                }
                break
            case InboxFilterButtonsTag.unread.rawValue:
                //print("unread filtered")
                if filterApplied == true {
                    if appliedFiltersText.count > 0 {
                        appliedFiltersText = appliedFiltersText + ", Unread"
                    } else {
                        appliedFiltersText = "Unread"
                    }
                }
                break
            case InboxFilterButtonsTag.withAttachment.rawValue:
                //print("with attachment filtered")
                if filterApplied == true {
                    if appliedFiltersText.count > 0 {
                        appliedFiltersText = appliedFiltersText + ", With attachments"
                    } else {
                        appliedFiltersText = "With attachments"
                    }
                }
                break
            default:
                print("default")
            }
        }
        
        return appliedFiltersText
    }
    
    func showUndoBar(text: String) {
        
        print("show undo bar")
        
        self.viewController?.undoButton.setTitle(text, for: .normal)
        
        self.viewController?.undoBar.isHidden = false
        //self.viewController?.undoBar.alpha = 1.0
        
        //let duration = k_undoActionBarShowingSecs
        
        /*
        UIView.animate(withDuration: duration, delay: 0.0, options: .allowUserInteraction, animations: {
            self.viewController?.undoBar.alpha = 0.1
        }, completion: { _ in
            self.hideUndoBar()
        })*/
        
        counter = 0
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fadeUndoBar), userInfo: nil, repeats: true)
    }
    
    @objc func fadeUndoBar() {
        
        counter +=  1
        let alpha = 1.0/Double(counter)
        self.viewController?.undoButton.alpha = CGFloat(alpha)
        
        if counter == Int(k_undoActionBarShowingSecs) {
            self.hideUndoBar()
        }
    }
    
    func hideUndoBar() {
        
        counter = 0
        timer.invalidate()
        self.viewController?.undoBar.isHidden = true
        self.viewController?.undoButton.alpha = 1.0
    }
    
    //MARK: - More Actions
    
    func initMoreActionsView() {
        
        self.viewController?.moreActionsView = Bundle.main.loadNibNamed(k_MoreActionsViewXibName, owner: nil, options: nil)?.first as? MoreActionsView
        self.viewController?.moreActionsView?.frame = CGRect(x: 0.0, y: 0.0, width: self.viewController!.view.frame.width, height: self.viewController!.view.frame.height)
        self.viewController?.moreActionsView?.delegate = self.viewController
        
        self.viewController?.navigationController!.view.addSubview((self.viewController?.moreActionsView)!)
        
        self.viewController?.moreActionsView?.isHidden = true
    }
    
    func showMoreActionsView(emptyFolder: Bool) {
        
        var moreActionsButtonsName: Array<String> = []
        
        if emptyFolder {
            moreActionsButtonsName = self.setupMoreActionsButtonsEmptyFolder()
        } else {
            moreActionsButtonsName = self.setupMoreActionsButtons()
        }
        
        self.viewController?.moreActionsView?.setup(buttonsNameArray: moreActionsButtonsName)
        
        let hidden = self.viewController?.moreActionsView?.isHidden
        
        self.viewController?.moreActionsView?.isHidden = !hidden!
    }
    
    func setupMoreActionsButtonsEmptyFolder() -> Array<String> {
        
        let moreActionsButtonsName: Array<String> = ["cancel".localized(), "emptyFolder".localized()]
        
        return moreActionsButtonsName
    }
    
    func setupMoreActionsButtons() -> Array<String> {
        
        let currentFolder = self.viewController?.currentFolderFilter
        
        let read = self.needReadAction()
        var readButton : String = ""
        
        if read {
            readButton = "markAsRead".localized()
        } else {
            readButton = "markAsUnread".localized()
        }
        
        var moreActionsButtonsName: Array<String> = []
        
        switch currentFolder {
        case MessagesFoldersName.inbox.rawValue:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToArchive".localized()]
            break
        case MessagesFoldersName.draft.rawValue:
            moreActionsButtonsName = []
            break
        case MessagesFoldersName.sent.rawValue:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToArchive".localized()]
            break
        case MessagesFoldersName.outbox.rawValue:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToArchive".localized(), "moveToInbox".localized()]
            break
        case MessagesFoldersName.starred.rawValue:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToArchive".localized(), "moveToInbox".localized()]
            break
        case MessagesFoldersName.archive.rawValue:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToInbox".localized()]
            break
        case MessagesFoldersName.spam.rawValue:
            moreActionsButtonsName = ["cancel".localized(), "moveToArchive".localized(), "moveToInbox".localized()]
            break
        case MessagesFoldersName.trash.rawValue:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToArchive".localized(), "moveToInbox".localized()]
            break
        default:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToArchive".localized(), "moveToInbox".localized()] //for custom folders
            break
        }
        
        return moreActionsButtonsName
    }
    
    func applyMoreAction(_ sender: AnyObject, isButton: Bool) {
        
        if isButton {
            
            let button = sender as! UIButton
            
            let title = button.title(for: .normal)
            
            print("title:", title as Any)
            
            switch title {
            case MoreActionsTitles.cancel.rawValue.localized():
                print("cancel btn more actions")
                
                break
            case MoreActionsTitles.markAsRead.rawValue.localized():
                print("markAsRead btn more actions")
                self.markSelectedMessagesAsRead()
                break
            case MoreActionsTitles.markAsUnread.rawValue.localized():
                print("markAsUnread btn more actions")
                self.markSelectedMessagesAsRead()
                break
            case MoreActionsTitles.moveToArchive.rawValue.localized():
                print("moveToArchive btn more actions")
                self.moveSelectedMessagesToArchive()
                break
            case MoreActionsTitles.moveToInbox.rawValue.localized():
                print("moveToInbox btn more actions")
                self.moveSelectedMessagesToInbox()
                break
            case MoreActionsTitles.emptyFolder.rawValue.localized():
                print("emptyFolder btn more actions")
                self.applyEmptyFolderAction()
                break
            default:
                print("more actions: default")
            }
        }
        
        self.showMoreActionsView(emptyFolder: false)
    }
    
    func applyEmptyFolderAction() {
        
        if (self.viewController?.dataSource?.messagesArray.count)! > 0 {
        
            self.viewController?.dataSource?.selectedMessagesIDArray = self.allMessagesID()
            self.viewController?.appliedActionMessage = self.viewController?.dataSource?.messagesArray.first
            
            if self.viewController?.currentFolderFilter == MessagesFoldersName.trash.rawValue {
                self.deleteMessagesPermanently()
            }
            
            if self.viewController?.currentFolderFilter == MessagesFoldersName.spam.rawValue {
                self.markSelectedMessagesAsTrash()
            }
        } else {
            
        }
    }
    
    func allMessagesID() -> Array<Int> {
        
        var messagesID : Array<Int> = []
        
        for message in (self.viewController?.dataSource?.messagesArray)! {
            if let messageID = message.messsageID {
                messagesID.append(messageID)
            }
        }
        
        return messagesID
    }
    
    func needReadAction() -> Bool {
        
        for messageID in (self.viewController?.dataSource?.selectedMessagesIDArray)! {
            for message in (self.viewController?.dataSource?.messagesArray)! {
                if messageID == message.messsageID {
                    if let read = message.read {
                        if !read {
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    //MARK: - Actions with Selected Messages
    
    func markSelectedMessagesAsSpam() {
        
        if self.viewController?.appliedActionMessage != nil {
            if (self.viewController?.dataSource?.selectedMessagesIDArray.count)! > 0 {
                self.interactor?.markMessagesListAsSpam(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, lastSelectedMessage: (self.viewController?.appliedActionMessage!)!, withUndo: "undoMarkAsSpam".localized())
            } else {
                print("messages not selected!!!")
            }
        }
    }
    
    func markSelectedMessagesAsRead() {
        
        if self.viewController?.appliedActionMessage != nil {
            if (self.viewController?.dataSource?.selectedMessagesIDArray.count)! > 0 {
                
                let read = self.viewController?.appliedActionMessage!.read
                
                var undoMessage = ""
                if read! {
                    undoMessage = "undoMarkAsUnread".localized()
                } else {
                    undoMessage = "undoMarkAsRead".localized()
                }
                
                self.interactor?.markMessagesListAsRead(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, asRead: !read!, withUndo: undoMessage)
            } else {
                print("messages not selected!!!")
            }
        }
    }
    
    func markSelectedMessagesAsTrash() {
        
        if self.viewController?.appliedActionMessage != nil {
            if (self.viewController?.dataSource?.selectedMessagesIDArray.count)! > 0 {
                self.interactor?.markMessagesListAsTrash(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, lastSelectedMessage: (self.viewController?.appliedActionMessage!)!, withUndo: "undoMoveToTrash".localized())
            } else {
                print("messages not selected!!!")
            }
        }
    }
    
    func moveSelectedMessagesToArchive() {
        
        if self.viewController?.appliedActionMessage != nil {
            if (self.viewController?.dataSource?.selectedMessagesIDArray.count)! > 0 {
                self.interactor?.moveMessagesListToArchive(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, lastSelectedMessage: (self.viewController?.appliedActionMessage!)!, withUndo: "undoMoveToArchive".localized())
            } else {
                print("messages not selected!!!")
            }
        }
    }
    
    func moveSelectedMessagesToInbox() {
        
        if self.viewController?.appliedActionMessage != nil {
            if (self.viewController?.dataSource?.selectedMessagesIDArray.count)! > 0 {
                self.interactor?.moveMessagesListToInbox(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, lastSelectedMessage: (self.viewController?.appliedActionMessage!)!, withUndo: "undoMoveToInbox".localized())
            } else {
                print("messages not selected!!!")
            }
        }
    }
    
    func deleteMessagesPermanently() {
     
        let params = Parameters(
            title: "deleteTitle".localized(),
            message: "deleteMessage".localized(),
            cancelButton: "cancelButton".localized(),
            otherButtons: ["deleteButton".localized()]
        )
        
        AlertHelperKit().showAlertWithHandler(self.viewController!, parameters: params) { buttonIndex in
            switch buttonIndex {
            case 0:
                print("Cancel Delete")
            default:
                print("Delete")
                self.interactor?.deleteMessagesList(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, withUndo: "")
            }
        }
    }
}

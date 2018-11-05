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
    
    func loadMessages(folder: String) {
        
        self.interactor?.messagesList(folder: folder, withUndo: "")
      
        // temp
        /*
        var messagesArray : Array<Any> = []
        let message : [String: Any] = ["sender" : "Dmitry3@dev.cetemplar.com", "id" : 1, "destruct_date" : "date"]
        messagesArray.append(message)
        
        let emailMessages = EmailMessagesList(dictionary: ["results" : messagesArray, "total_count" : 1])
        self.interactor?.setInboxData(messages: emailMessages)
        
        self.viewController?.dataSource?.reloadData()
 */
        //
    }
    
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
        
        if emailsCount > 0 {
            viewController?.emptyInbox.isHidden = true
            viewController?.advancedToolBar.isHidden = false
        } else {
            viewController?.emptyInbox.isHidden = false
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
    
    //MARK: - Side Menu
    
    func initAndSetupInboxSideMenuController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxSideMenuStoryboardName, bundle: nil)
        //let vc = storyboard.instantiateViewController(withIdentifier: k_InboxSideMenuViewControllerID) as! InboxSideMenuViewController
        self.viewController?.inboxSideMenuViewController = storyboard.instantiateViewController(withIdentifier: k_InboxSideMenuViewControllerID) as? InboxSideMenuViewController
        
        
        //vc.currentParentViewController = self.viewController
        
        //let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: vc)
        
        self.viewController?.inboxSideMenuViewController?.currentParentViewController = self.viewController
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: (self.viewController?.inboxSideMenuViewController)!)
        
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuAnimationFadeStrength = 0.5
        SideMenuManager.default.menuAnimationBackgroundColor = k_sideMenuFadeColor
        
        SideMenuManager.default.menuPresentMode = .viewSlideInOut
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
    
    func searchButtonPressed(sender: AnyObject) {
        
        if self.viewController?.dataSource?.selectionMode == true {
            disableSelectionMode()
        } else {
            //self.viewController?.router?.showMoveToViewController()//temp
        }
    }
    
    func enableSelectionMode() {
        
        self.viewController?.dataSource?.selectionMode = true
        self.viewController?.dataSource?.reloadData()
        
        self.viewController?.leftBarButtonItem.image = nil
        self.viewController?.leftBarButtonItem.isEnabled = false
        self.viewController?.rightBarButtonItem.image = nil
        self.viewController?.rightBarButtonItem.title = "Cancel"
        
        self.viewController?.selectionToolBar.isHidden = false
        
        setupNavigationItemTitle(selectedMessages: (self.viewController?.dataSource?.selectedMessagesIDArray.count)!, selectionMode: (self.viewController?.dataSource?.selectionMode)!, currentFolder: self.viewController!.currentFolder)
        
        self.viewController?.appliedActionMessage = nil
        self.viewController?.dataSource?.selectedMessagesIDArray.removeAll()
    }
    
    func disableSelectionMode() {
        
        self.viewController?.dataSource?.selectionMode = false
        self.viewController?.dataSource?.selectedMessagesIDArray.removeAll()
        self.viewController?.dataSource?.reloadData()
        
        self.viewController?.leftBarButtonItem.image = UIImage(named: k_menuImageName)
        self.viewController?.leftBarButtonItem.isEnabled = true
        self.viewController?.rightBarButtonItem.image = UIImage(named: k_searchImageName)
        self.viewController?.rightBarButtonItem.title = ""
        
        self.viewController?.selectionToolBar.isHidden = true
        
        setupNavigationItemTitle(selectedMessages: (self.viewController?.dataSource?.selectedMessagesIDArray.count)!, selectionMode: (self.viewController?.dataSource?.selectionMode)!, currentFolder: self.viewController!.currentFolder)
        
        self.viewController?.appliedActionMessage = nil
        self.viewController?.dataSource?.selectedMessagesIDArray.removeAll()
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
        self.viewController?.undoBar.alpha = CGFloat(alpha)
        
        if counter == Int(k_undoActionBarShowingSecs) {
            self.hideUndoBar()
        }
    }
    
    func hideUndoBar() {
        
        counter = 0
        timer.invalidate()
        self.viewController?.undoBar.isHidden = true
        self.viewController?.undoBar.alpha = 1.0
    }
    
    //MARK: - More Actions
    
    func initMoreActionsView() {
        
        self.viewController?.moreActionsView = Bundle.main.loadNibNamed(k_MoreActionsViewXibName, owner: nil, options: nil)?.first as? MoreActionsView
        self.viewController?.moreActionsView?.frame = CGRect(x: 0.0, y: 0.0, width: self.viewController!.view.frame.width, height: self.viewController!.view.frame.height)
        self.viewController?.moreActionsView?.delegate = self.viewController
        let moreActionsButtonsName: Array<String> = ["cancel".localized(), "markAsUnread".localized(), "moveToArchive".localized()]
        self.viewController?.moreActionsView?.setup(buttonsNameArray: moreActionsButtonsName)
        self.viewController?.navigationController!.view.addSubview((self.viewController?.moreActionsView)!)
        
        self.viewController?.moreActionsView?.isHidden = true
    }
    
    func showMoreActionsView() {
        
        let hidden = self.viewController?.moreActionsView?.isHidden
        
        self.viewController?.moreActionsView?.isHidden = !hidden!
    }
    
    func applyMoreAction(_ sender: AnyObject) {
        
        self.showMoreActionsView()
        
        switch sender.tag {
            
        case MoreViewButtonsTag.cancel.rawValue:
            print("cancel btn more actions")
            
            break
        case MoreViewButtonsTag.bottom.rawValue:
            print("bottom btn action")
            self.markSelectedMessagesAsRead()
            break
        case MoreViewButtonsTag.middle.rawValue:
            print("middle btn action")
            self.moveSelectedMessagesToArchive()
            break
        case MoreViewButtonsTag.upper.rawValue:
            print("upper btn action")
            
            break
        default:
            print("more actions: default")
        }
    }
    
    //MARK: - Actions with Selected Messages
    
    func markSelectedMessagesAsSpam() {
        
        if self.viewController?.appliedActionMessage != nil {
            if (self.viewController?.dataSource?.selectedMessagesIDArray.count)! > 0 {
                self.interactor?.markMessagesListAsSpam(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, lastSelectedMessage: (self.viewController?.appliedActionMessage!)!, withUndo: "Undo mark as spam")
            } else {
                print("messages not selected!!!")
            }
        }
    }
    
    func markSelectedMessagesAsRead() {
        
        if self.viewController?.appliedActionMessage != nil {
            if (self.viewController?.dataSource?.selectedMessagesIDArray.count)! > 0 {
                self.interactor?.markMessagesListAsRead(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, lastSelectedMessage: (self.viewController?.appliedActionMessage!)!, withUndo: "Undo mark as read")
            } else {
                print("messages not selected!!!")
            }
        }
    }
    
    func markSelectedMessagesAsTrash() {
        
        if self.viewController?.appliedActionMessage != nil {
            if (self.viewController?.dataSource?.selectedMessagesIDArray.count)! > 0 {
                self.interactor?.markMessagesListAsTrash(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, lastSelectedMessage: (self.viewController?.appliedActionMessage!)!, withUndo: "Undo delete")
            } else {
                print("messages not selected!!!")
            }
        }
    }
    
    func moveSelectedMessagesToArchive() {
        
        if self.viewController?.appliedActionMessage != nil {
            if (self.viewController?.dataSource?.selectedMessagesIDArray.count)! > 0 {
                self.interactor?.moveMessagesListToArchive(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, lastSelectedMessage: (self.viewController?.appliedActionMessage!)!, withUndo: "Undo move to archive")
            } else {
                print("messages not selected!!!")
            }
        }
    }
}

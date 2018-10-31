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
    
    //MARK: - API Requests
    
    func loadMessages(folder: String) {
        
        self.interactor?.messagesList(folder: folder)
      
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
        } else {
            viewController?.messagesLabel.text = formatEmailsCountText(emailsCount: emailsCount)
            viewController?.unreadMessagesLabel.text = formatUreadEmailsCountText(emailsCount: unreadEmails)
            viewController?.unreadMessagesLabel.textColor = k_lightGrayTextColor
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
        let vc = storyboard.instantiateViewController(withIdentifier: k_InboxSideMenuViewControllerID) as! InboxSideMenuViewController
        
        vc.currentParentViewController = self.viewController
        
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: vc)
        
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
        
        self.viewController?.undoButton.setTitle(text, for: .normal)
        
        self.viewController?.undoBar.isHidden = false
        self.viewController?.undoBar.alpha = 1.0
        
        let duration = k_undoActionBarShowingSecs
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .allowUserInteraction, animations: {
            self.viewController?.undoBar.alpha = 0.1
        }, completion: { _ in
            self.viewController?.undoBar.isHidden = true
        })
    }
}

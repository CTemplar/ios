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
    
    func loadMessages() {
        
        self.interactor?.messagesList()
      
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
    
    func setupUI(emailsCount: Int, unreadEmails: Int) {
        
        viewController?.messagesLabel.text = formatEmailsCountText(emailsCount: emailsCount)
        viewController?.unreadMessagesLabel.text = formatUreadEmailsCountText(emailsCount: unreadEmails)
        
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
    }
    
    //MARK: - Side Menu
    
    func initAndSetupInboxSideMenuController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxSideMenuStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_InboxSideMenuViewControllerID) as! InboxSideMenuViewController
        
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
    }
    
    //MARK: - filter
    
    func initFilterView() {
        
        self.viewController?.inboxFilterView = Bundle.main.loadNibNamed(k_InboxFilterViewXibName, owner: nil, options: nil)?.first as? InboxFilterView
        self.viewController?.inboxFilterView?.frame = CGRect(x: 0.0, y: 0.0, width: self.viewController!.view.frame.width, height: self.viewController!.view.frame.height - 0.0)
        self.viewController?.inboxFilterView?.delegate = self.viewController
        self.viewController?.inboxFilterView?.setup()
        self.viewController?.navigationController!.view.addSubview((self.viewController?.inboxFilterView)!)
        
        self.viewController?.inboxFilterView?.isHidden = true
    }
    
    func showFilterView() {
        
        let hidden = self.viewController?.inboxFilterView?.isHidden
        
        self.viewController?.inboxFilterView?.isHidden = !hidden!
        
        if !hidden! {
            self.viewController?.leftFilterButton.setImage(UIImage(named: k_filterImageName), for: .normal)
        } else {
            self.viewController?.leftFilterButton.setImage(UIImage(named: k_blackFilterImageName), for: .normal)
        }
    }
    
    func applyFilterAction(_ sender: AnyObject) {
        
        switch sender.tag {
        case InboxFilterButtonsTag.all.rawValue:
            print("filter: all")
            
            break
        case InboxFilterButtonsTag.starred.rawValue:
            print("filter: starred")
            
            break
        case InboxFilterButtonsTag.unread.rawValue:
            print("filter: unread")
            
            break
        case InboxFilterButtonsTag.withAttachment.rawValue:
            print("filter: withAttachment")
            
            break
        default:
            print("filter: default")
        }
    }
    
    func showUndoBar(text: String) {
        
        self.viewController?.undoButton.setTitle(text, for: .normal)
        
        self.viewController?.undoBar.isHidden = false
        self.viewController?.undoBar.alpha = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            self.viewController?.undoBar.isHidden = true
        })
        
        UIView.animate(withDuration: 5.0, animations: {
            self.viewController?.undoBar.alpha = 0.0
        })
    }
}

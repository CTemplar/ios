//
//  ViewInboxEmailPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ViewInboxEmailPresenter {
    
    var viewController   : ViewInboxEmailViewController?
    var interactor       : ViewInboxEmailInteractor?
    
    var timer = Timer()
    var counter = 0

    func setupNavigationBar() {
        
        let arrowBackImage = UIImage(named: k_darkBackArrowImageName)
        self.viewController?.navigationController?.navigationBar.backIndicatorImage = arrowBackImage
        self.viewController?.navigationController?.navigationBar.backIndicatorTransitionMaskImage = arrowBackImage
        
        self.viewController?.navigationController?.navigationBar.topItem?.title = ""
        self.viewController?.navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        let garbageButton : UIButton = UIButton.init(type: .custom)
        garbageButton.setImage(UIImage(named: k_garbageImageName), for: .normal)
        garbageButton.addTarget(self, action: #selector(garbageButtonPresed), for: .touchUpInside)
        garbageButton.frame = CGRect(x: 0, y: 0, width: k_navBarButtonSize, height: k_navBarButtonSize)
        let garbageItem = UIBarButtonItem(customView: garbageButton)
        
        let spamButton : UIButton = UIButton.init(type: .custom)
        spamButton.setImage(UIImage(named: k_spamImageName), for: .normal)
        spamButton.addTarget(self, action: #selector(spamButtonPresed), for: .touchUpInside)
        spamButton.frame = CGRect(x: 0, y: 0, width: k_navBarButtonSize, height: k_navBarButtonSize)
        let spamItem = UIBarButtonItem(customView: spamButton)
        
        let moveButton : UIButton = UIButton.init(type: .custom)
        moveButton.setImage(UIImage(named: k_moveImageName), for: .normal)
        moveButton.addTarget(self, action: #selector(moveButtonPresed), for: .touchUpInside)
        moveButton.frame = CGRect(x: 0, y: 0, width: k_navBarButtonSize, height: k_navBarButtonSize)
        let moveItem = UIBarButtonItem(customView: moveButton)
        
        let moreButton : UIButton = UIButton.init(type: .custom)
        moreButton.setImage(UIImage(named: k_moreImageName), for: .normal)
        moreButton.addTarget(self, action: #selector(moreButtonPresed), for: .touchUpInside)
        moreButton.frame = CGRect(x: 0, y: 0, width: k_navBarButtonSize, height: k_navBarButtonSize)
        let moreItem = UIBarButtonItem(customView: moreButton)
        
        self.viewController?.navigationItem.rightBarButtonItems = [moreItem, moveItem, spamItem, garbageItem]
    }
    
    func setupMessageHeader(message: EmailMessage) {
     
        self.viewController?.headerLabel.text = message.subject
        
        if let createdDate = message.createdAt {
            if  let date = self.interactor?.formatterService!.formatStringToDate(date: createdDate) {
                self.viewController?.dateLabel.text = self.interactor?.formatterService!.formatCreationDate(date: date)
            }
        }
        
        if let protected = message.isProtected {            
            if protected {
                self.viewController?.securedImageView.image = UIImage(named: k_secureOnImageName)
            } else {
                self.viewController?.securedImageView.image = UIImage(named: k_secureOffImageName)
            }
        }
        
        if let starred = message.starred {
            if starred {
                self.viewController?.starredmageView.image = UIImage(named: k_starOnImageName)
            } else {
                self.viewController?.starredmageView.image = UIImage(named: k_starOffImageName)
            }
        }
        
        var fromName: String = "Dmitry"
        var fromEmail: String = ""
        var toName: String = "Dima"
        var toEmail: String = ""
        var ccArray : Array<String> = []
        
        if let sender = message.sender {
            fromEmail = sender
        }
        
        if let recieversArray = message.receiver {
            
            if recieversArray.count > 0 {
                toEmail = recieversArray.first as! String
            }
        }
        
        if let carbonCopyArray = message.cc {
            ccArray = carbonCopyArray as! Array<String>
        }
        
        let fromToAttributtedString = self.interactor?.formatterService!.formatFromToAttributedString(fromName: fromName, fromEmail: fromEmail, toName: toName, toEmail: toEmail, ccArray: ccArray)
        
        
        self.viewController?.fromToBarTextView.attributedText = fromToAttributtedString
        
        if let messageContent = self.interactor?.extractMessageContent(message: message) {
        
            self.viewController?.contentTextView.isHidden = true
            //self.viewController?.contentTextView.attributedText = messageContent.html2AttributedString
            self.viewController?.webView.loadHTMLString(messageContent, baseURL: nil)
        }
    }
    
    //MARK: - NavBar Actions
    
    @objc func garbageButtonPresed() {
        
        self.interactor?.moveMessageToTrash(message: (self.viewController?.message)!, withUndo: "undoMoveToTrash".localized())
    }
    
    @objc func spamButtonPresed() {
        
        self.interactor?.moveMessageToSpam(message: (self.viewController?.message)!, withUndo: "undoMarkAsSpam".localized())
    }
    
    @objc func moveButtonPresed() {
        
        self.viewController?.router?.showMoveToViewController()        
    }
    
    @objc func moreButtonPresed() {
        
        self.showMoreActionsView()
    }
    
    //MARK: - Undo
    
    func showUndoBar(text: String) {
        
        print("show undo bar")
        
        self.viewController?.undoButton.setTitle(text, for: .normal)        
        self.viewController?.undoBar.isHidden = false
        
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
        
        self.viewController?.navigationController!.view.addSubview((self.viewController?.moreActionsView)!)
        
        self.viewController?.moreActionsView?.isHidden = true
    }
    
    func showMoreActionsView() {
        
        var moreActionsButtonsName: Array<String> = []

        moreActionsButtonsName = self.setupMoreActionsButtons()
        
        self.viewController?.moreActionsView?.setup(buttonsNameArray: moreActionsButtonsName)
        
        let hidden = self.viewController?.moreActionsView?.isHidden
        
        self.viewController?.moreActionsView?.isHidden = !hidden!
    }
    
    
    func setupMoreActionsButtons() -> Array<String> {
        
        let currentFolder = self.viewController?.currentFolderFilter
        
        var readButton : String = ""
        
        if (self.viewController?.messageIsRead)! {
            readButton = "markAsUnread".localized()
        } else {
            readButton = "markAsRead".localized()
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
    
    func applyMoreAction(_ sender: AnyObject) {
        
        let button = sender as! UIButton
        
        let title = button.title(for: .normal)
        
        print("title:", title as Any)
        
        switch title {
        case MoreActionsTitles.cancel.rawValue.localized():
            print("cancel btn more actions")
            break
        case MoreActionsTitles.markAsRead.rawValue.localized():
            print("markAsRead btn more actions")
            self.interactor?.markMessageAsRead(message: (self.viewController?.message)!, asRead: true, withUndo: "undoMarkAsRead".localized())
            break
        case MoreActionsTitles.markAsUnread.rawValue.localized():
            print("markAsUnread btn more actions")
            self.interactor?.markMessageAsRead(message: (self.viewController?.message)!, asRead: false, withUndo: "undoMarkAsUnread".localized())
            break
        case MoreActionsTitles.moveToArchive.rawValue.localized():
            print("moveToArchive btn more actions")
            self.interactor?.moveMessageToArchive(message: (self.viewController?.message)!, withUndo: "undoMoveToInbox".localized())
            break
        case MoreActionsTitles.moveToInbox.rawValue.localized():
            print("moveToInbox btn more actions")
            self.interactor?.moveMessageToInbox(message: (self.viewController?.message)!, withUndo: "undoMoveToInbox".localized())
            break
        case MoreActionsTitles.emptyFolder.rawValue.localized():
            print("emptyFolder btn more actions")
            break
        default:
            print("more actions: default")
        }
        
        self.showMoreActionsView()
    }
}

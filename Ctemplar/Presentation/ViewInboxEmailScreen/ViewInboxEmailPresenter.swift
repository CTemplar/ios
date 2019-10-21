//
//  ViewInboxEmailPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import PKHUD
import AlertHelperKit

class ViewInboxEmailPresenter {
    
    var k_popoverSourceRectX          = 0
    var k_popoverSourceRectY          = 0
    
    var viewController   : ViewInboxEmailViewController?
    var interactor       : ViewInboxEmailInteractor?
    
    var timer = Timer()
    var counter = 0

    func setupNavigationBar(enabled: Bool) {
        
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
        
        moreItem.isEnabled = enabled
        moveItem.isEnabled = enabled
        spamItem.isEnabled = enabled
        garbageItem.isEnabled = enabled
        
        let folder = self.viewController?.message?.folder
        
        if folder == MessagesFoldersName.spam.rawValue {
            self.viewController?.navigationItem.rightBarButtonItems = [moreItem, moveItem, garbageItem]
        } else {
            self.viewController?.navigationItem.rightBarButtonItems = [moreItem, moveItem, spamItem, garbageItem]
        }
        
        k_popoverSourceRectX = Int((self.viewController?.view.frame.width)! - 40.0)
        k_popoverSourceRectY = Int(57.0)
    }
    
    func setupMessageHeader(message: EmailMessage) {
     
        self.setupSubjectLabel(message: message)
        
        if let createdDate = message.createdAt {
            if  let date = self.interactor?.formatterService!.formatStringToDate(date: createdDate) {
                self.viewController?.dateLabel.text = self.interactor?.formatterService!.formatCreationDate(date: date, short: false)
            }
        }
        
        if let protected = message.isProtected {            
            if protected {
                self.viewController?.securedImageView.image = UIImage(named: k_secureOnImageName)
            } else {
                self.viewController?.securedImageView.image = UIImage(named: k_secureOffImageName)
            }
        }
        
        if let starred = self.viewController?.messageIsStarred {
            self.setupStarredButton(starred: starred)
        }
        
        self.setupFromToHeaderHeight(message: message)
        //self.setupPropertyLabel(message: message)

    }
    
    func setupMessageContent(message: EmailMessage) {
        /*
        if let messageContent = self.interactor?.extractMessageContent(message: message) {
            
            //self.viewController?.contentTextView.isHidden = true
            //self.viewController?.webView.isHidden = false
            
            self.viewController?.contentTextView.isHidden = false
            self.viewController?.webView.isHidden = true
            
            self.viewController?.contentTextView.attributedText = messageContent.html2AttributedString
            //self.viewController?.contentTextView.text = messageContent.html2String
            self.viewController?.webView.loadHTMLString(messageContent, baseURL: nil)
        }*/
        
        self.viewController?.contentTextView.attributedText = NSAttributedString(string: "decrypting...")
        
        self.interactor?.extractMessageContentAsync(message: message)
        self.viewController?.contentTextView.isHidden = false
        self.viewController?.webView.isHidden = true
    }
    
    func setupFromToHeaderHeight(message: EmailMessage) {
        
        var fromName: String = ""
        var fromEmail: String = ""
        var toNamesArray : Array<String> = []
        var toEmailsArray : Array<String> = []
        var ccArray : Array<String> = []
        var bccArray : Array<String> = []
        
        if let sender = message.sender {
            fromEmail = sender
        }
        
        if let recieversArray = message.receivers {
            toEmailsArray = recieversArray as! Array<String>
        }
        
        if let carbonCopyArray = message.cc {
            ccArray = carbonCopyArray as! Array<String>
        }
        
        if let bcarbonCopyArray = message.bcc {
            bccArray = bcarbonCopyArray as! Array<String>
        }
        /*
        //temp names
        toEmailsArray.append("oak777@unet.lg.ua")
        toEmailsArray.append("support5464@hypertunnels3d.com")
        toEmailsArray.append("huly-gun4444@white-zebra.com")
        
        toNamesArray.append("Dima")
        toNamesArray.append("Dimon")
        toNamesArray.append("MegaDima")
        
        //temp carbon
        ccArray.append("oak@unet.lg.ua")
        ccArray.append("support@hypertunnels3d.com")
        ccArray.append("huly-gun@white-zebra.com")
        ccArray.append("supportxx@hypertunnels3d.com")
        ccArray.append("huly-gunxx@white-zebra.com")
        */
        
        let fromToText = self.interactor?.formatterService!.formatFromToString(fromName: fromName, fromEmail: fromEmail, toNamesArray: toNamesArray, toEmailsArray: toEmailsArray, ccArray: ccArray, bccArray: bccArray)
        
        let fromToAttributtedString = self.interactor?.formatterService!.formatFromToAttributedString(fromName: fromName, fromToText: fromToText!, toNamesArray: toNamesArray, toEmailsArray: toEmailsArray, ccArray: ccArray, bccArray: bccArray)
        
        self.viewController?.fromToBarTextView.contentInset = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        self.viewController?.fromToBarTextView.attributedText = fromToAttributtedString
        
        let numberOfLines = fromToText?.numberOfLines()
        //print("numberOfLines:", numberOfLines as Any)
        
        var fromToViewHeight = k_lineHeightForFromToText * CGFloat(numberOfLines!)
        
        if fromToViewHeight < k_fromToViewMinHeight {
            fromToViewHeight = k_fromToViewMinHeight
        } else {
            fromToViewHeight = (k_lineHeightForFromToText * CGFloat(numberOfLines!))  + k_InsetsForFromTo
        }        
        
        self.viewController?.fromToViewHeightConstraint.constant = fromToViewHeight
        self.viewController?.topViewHeightConstraint.constant = fromToViewHeight + k_dateLabelOffsetHeight
        
        self.viewController?.view.layoutIfNeeded()
    }
    
    func setupBottomBar(enabled: Bool) {
        
        self.viewController?.replyButton.isEnabled = enabled
        self.viewController?.replyAllButton.isEnabled = enabled
        self.viewController?.forwardButton.isEnabled = enabled
    }
    
    func setupStarredButton(starred: Bool) {
        
        if starred {
            self.viewController?.starredButton.setImage(UIImage(named: k_starOnBigImageName), for: .normal)
        } else {
            self.viewController?.starredButton.setImage(UIImage(named: k_starOffBigImageName), for: .normal)
        }
    }
    
    func setupSubjectLabel(message: EmailMessage) {
        
        self.interactor?.updateSubject(message: message)       
    }
    
    func setSubjectLabel(subject: String) {
        
        self.viewController?.headerLabel.text = subject
        
        let subjectTextWidth : CGFloat  = (self.viewController?.headerLabel.text!.widthOfString(usingFont: (self.viewController?.headerLabel.font)!))!
        
        if subjectTextWidth < (self.viewController?.view.frame.width)! - k_rightOffsetForSubjectLabel {
            self.viewController?.headerLabelWidthConstraint.constant = subjectTextWidth
        } else {
            self.viewController?.headerLabelWidthConstraint.constant = (self.viewController?.view.frame.width)! - k_rightOffsetForSubjectLabel
        }
    }
    
    func setupPropertyLabel(message: EmailMessage) {
        
        if let delayedDelivery = message.delayedDelivery {
            self.viewController?.propertyLabel.isHidden = false
            self.viewController?.propertylabelView.backgroundColor = k_greenColor
            if  let date = interactor?.formatterService!.formatDestructionTimeStringToDate(date: delayedDelivery) {
                self.viewController?.propertyLabel.attributedText = date.timeCountForDelivery(short: false)
            } else {
                if let date = interactor?.formatterService!.formatDestructionTimeStringToDateTest(date: delayedDelivery) {
                    self.viewController?.propertyLabel.attributedText = date.timeCountForDelivery(short: false)
                } else {
                    self.viewController?.propertyLabel.attributedText = NSAttributedString(string: "Error")
                }
            }
        }
        
        //self.viewController?.propertyLabelViewWidthConstraint = 
               /*
               if let deadManDuration = message.deadManDuration {
                   leftlabelView.isHidden = false
                   leftlabelView.backgroundColor = k_redColor
                   if  let date = parentController?.formatterService!.formatDeadManDateString(duration: deadManDuration, short: short) {
                       leftLabel.attributedText = date
                   } else {
                       leftLabel.attributedText = NSAttributedString(string: "Error")
                   }
               }
               
               //let testDate = "2018-10-26T13:00:00Z"
               //2018-12-18T05:18:17.919000Z error
               //web 2018-12-30T19:00:00Z
               if let destructionDate = message.destructDay {
                   rightlabelView.isHidden = false
                   rightlabelView.backgroundColor = k_orangeColor
                   //print("destructionDate:", destructionDate)
                   if  let date = parentController?.formatterService!.formatDestructionTimeStringToDate(date: destructionDate) {
                       deleteLabel.attributedText = date.timeCountForDestruct(short: short)
                   } else {
                       //print("erorr formatting destructionDate:", destructionDate)
                       if let date = parentController?.formatterService!.formatDestructionTimeStringToDateTest(date: destructionDate) {
                           print("new format date:", date)
                           deleteLabel.attributedText = date.timeCountForDestruct(short: short)
                       } else {
                           deleteLabel.attributedText = NSAttributedString(string: "Error")
                       }
                   }
               }*/
    }
    
    //MARK: - Attachment Action
    
    func showShareScreen(itemUrlString: String, encrypted: Bool) {
        
        let url = self.interactor?.getFileUrlDocuments(withURLString: itemUrlString)
    
        if (self.interactor?.checkIsFileExist(url: url!))! {            
            self.interactor?.showPreviewScreen(url: url!, encrypted: encrypted)
        } else {
            self.interactor?.loadAttachFile(url: itemUrlString, encrypted: encrypted)
        }
    }
    
    func showAttachmentError() {
        
        AlertHelperKit().showAlert(self.viewController!, title: "Attachment Error", message: "Attachment File is corrupted or cannot be decrypted", button: "closeButton".localized())
    }
        
    //MARK: - Read Actions
    
    func checkMessaseReadStatus(message: EmailMessage) {
        
        if let read = message.read {
            
            if read == false {
                self.setMessageAsRead()
            }
        }
    }
    
    func setMessageAsRead() {
        
        self.interactor?.markMessageAsRead(message: (self.viewController?.message)!, asRead: true, withUndo: "")
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
        
       // self.showMoreActionsView()
        
        if (!Device.IS_IPAD) {
            self.showMoreActionsView()
        } else {
            self.showMoreActionsActionSheet()
        }
    }
    
    func starButtonPressed() {
        
        self.viewController?.messageIsStarred = !(self.viewController?.messageIsStarred)!
        
        self.interactor?.markMessageAsStarred(message: (self.viewController?.message)!, starred: (self.viewController?.messageIsStarred)!, withUndo: "")
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
                //self.interactor?.markMessageAsRead(message: (self.viewController?.message)!, asRead: true, withUndo: "undoMarkAsRead".localized())
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
                break
            default:
                print("more actions: default")
            }
        }
        
        self.showMoreActionsView()
    }
    
    func showMoreActionsActionSheet() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        self.configureMoreActionsActionSheet(alertController: alertController)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = viewController?.view
            popoverController.sourceRect = CGRect(x: k_popoverSourceRectX, y: k_popoverSourceRectY, width: 0, height: 0)
        }
        
        viewController?.present(alertController, animated: true, completion: nil)
    }
    
    func configureMoreActionsActionSheet(alertController: UIAlertController) {
        
        let currentFolder = self.viewController?.currentFolderFilter
        
        var readButton : String = ""
        
        if (self.viewController?.messageIsRead)! {
            readButton = "markAsUnread".localized()
        } else {
            readButton = "markAsRead".localized()
        }
        
        var actionsList: Array<UIAlertAction> = []
        
        let readMessageAction = UIAlertAction(title: readButton, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.markSelectedMessagesAsRead()
        })
        
        let moveToInboxAction = UIAlertAction(title: "moveToInbox".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.moveSelectedMessagesToInbox()
        })
        
        let moveToArchiveAction = UIAlertAction(title: "moveToArchive".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.moveSelectedMessagesToArchive()
        })
        
        switch currentFolder {
        case MessagesFoldersName.inbox.rawValue:
            actionsList = [readMessageAction, moveToArchiveAction]
            break
        case MessagesFoldersName.draft.rawValue:
            
            break
        case MessagesFoldersName.sent.rawValue:
            actionsList = [readMessageAction, moveToArchiveAction]
            break
        case MessagesFoldersName.outbox.rawValue:
            actionsList = [readMessageAction, moveToArchiveAction, moveToInboxAction]
            break
        case MessagesFoldersName.starred.rawValue:
            actionsList = [readMessageAction, moveToArchiveAction, moveToInboxAction]
            break
        case MessagesFoldersName.archive.rawValue:
            actionsList = [readMessageAction, moveToInboxAction]
            break
        case MessagesFoldersName.spam.rawValue:
            actionsList = [readMessageAction, moveToArchiveAction, moveToInboxAction]
            break
        case MessagesFoldersName.trash.rawValue:
            
            break
        default:
            actionsList = [readMessageAction, moveToArchiveAction, moveToInboxAction]
            break
        }
        
        for action in actionsList {
            alertController.addAction(action)
        }
    }
    
    func markSelectedMessagesAsRead() {
        
        let read = self.viewController?.messageIsRead
        
        var undoMessage = ""
        if read! {
            undoMessage = "undoMarkAsUnread".localized()
        } else {
            undoMessage = "undoMarkAsRead".localized()
        }
        
        self.interactor?.markMessageAsRead(message: (self.viewController?.message)!, asRead: !read!, withUndo: undoMessage)
    }
    
    func moveSelectedMessagesToArchive() {
        
        self.interactor?.moveMessageToArchive(message: (self.viewController?.message)!, withUndo: "undoMoveToArchive".localized())
    }
    
    func moveSelectedMessagesToInbox() {
        
        self.interactor?.moveMessageToInbox(message: (self.viewController?.message)!, withUndo: "undoMoveToInbox".localized())
    }
}

//
//  ViewInboxEmailPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility
import Networking

class ViewInboxEmailPresenter {
    
    var k_popoverSourceRectX = 0
    var k_popoverSourceRectY = 0
    
    var viewController: ViewInboxEmailViewController?
    var interactor: ViewInboxEmailInteractor?
    
    var timer = Timer()
    var counter = 0

    func setupNavigationBar(enabled: Bool) {
        self.viewController?.navigationController?.navigationBar.topItem?.title = ""
        
        let garbageButton = UIButton(type: .custom)
        garbageButton.setImage(UIImage(named: k_garbageImageName), for: .normal)
        garbageButton.addTarget(self, action: #selector(garbageButtonPresed), for: .touchUpInside)
        garbageButton.frame = CGRect(x: 0, y: 0, width: k_navBarButtonSize, height: k_navBarButtonSize)
        let garbageItem = UIBarButtonItem(customView: garbageButton)
        
        let spamButton = UIButton(type: .custom)
        spamButton.setImage(UIImage(named: k_spamImageName), for: .normal)
        spamButton.addTarget(self, action: #selector(spamButtonPresed), for: .touchUpInside)
        spamButton.frame = CGRect(x: 0, y: 0, width: k_navBarButtonSize, height: k_navBarButtonSize)
        let spamItem = UIBarButtonItem(customView: spamButton)
        
        let moveButton = UIButton(type: .custom)
        moveButton.setImage(UIImage(named: k_moveImageName), for: .normal)
        moveButton.addTarget(self, action: #selector(moveButtonPresed), for: .touchUpInside)
        moveButton.frame = CGRect(x: 0, y: 0, width: k_navBarButtonSize, height: k_navBarButtonSize)
        let moveItem = UIBarButtonItem(customView: moveButton)
        
        let moreButton = UIButton(type: .custom)
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
                self.viewController?.dateLabel.text = self.interactor?.formatterService!.formatCreationDate(date: date, short: false, useFullDate: true)
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
    }
    
    func setupMessageContent(message: EmailMessage) {
        self.viewController?.contentTextView.attributedText = NSAttributedString(string: "decrypting...")
        self.interactor?.extractMessageContentAsync(message: message)
        self.viewController?.contentTextView.isHidden = false
        self.viewController?.webView.isHidden = true
    }
    
    func setupFromToHeaderHeight(message: EmailMessage) {
        
        let fromName: String = ""
        var fromEmail: String = ""
        let toNamesArray : Array<String> = []
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
        
        let fromToText = self.interactor?.formatterService!.formatFromToString(fromName: fromName, fromEmail: fromEmail, toNamesArray: toNamesArray, toEmailsArray: toEmailsArray, ccArray: ccArray, bccArray: bccArray)
        
        let fromToAttributtedString = self.interactor?.formatterService!.formatFromToAttributedString(fromName: fromName, fromToText: fromToText!, toNamesArray: toNamesArray, toEmailsArray: toEmailsArray, ccArray: ccArray, bccArray: bccArray)
        
        self.viewController?.fromToBarTextView.contentInset = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        self.viewController?.fromToBarTextView.attributedText = fromToAttributtedString
        
        let numberOfLines = fromToText?.numberOfLines()
        
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
        self.viewController?.showAlert(with: "Attachment Error",
                   message: "Attachment File is corrupted or cannot be decrypted",
                   buttonTitle: Strings.Button.closeButton.localized)
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
    @objc
    func garbageButtonPresed() {
        viewController?.showBanner(withTitle: "movingToTrash".localized(),
                                        additionalConfigs: [.displayDuration(.infinity),
                                                            .showButton(false)]
        )
        self.interactor?.moveMessageToTrash(message: (self.viewController?.message)!, withUndo: "undoMoveToTrash".localized(), onCompletion: { [weak self] (isSucceeded) in
            DispatchQueue.main.async {
                if isSucceeded {
                    self?.viewController?.router?.backToParentViewController()
                    self?.viewController?.showBannerAgain(withUpdatedText: "done".localized(),
                                                         additionalConfigs: [.displayDuration(2.0),
                                                                             .showButton(true)]
                    )
                } else {
                    self?.viewController?.showBannerAgain(withUpdatedText: "actionFailed".localized(),
                                                         additionalConfigs: [.displayDuration(2.0),
                                                                             .showButton(true)]
                    )
                }
            }
        })
    }
    
    @objc
    func spamButtonPresed() {
        viewController?.showBanner(withTitle: "movingToSpam".localized(),
                                        additionalConfigs: [.displayDuration(.infinity),
                                                            .showButton(false)]
        )
        self.interactor?.moveMessageToSpam(message: (self.viewController?.message)!, withUndo: "undoMarkAsSpam".localized(), onCompletion: { [weak self] (isSucceeded) in
            if isSucceeded {
                self?.viewController?.router?.backToParentViewController()
                self?.viewController?.showBannerAgain(withUpdatedText: "done".localized(),
                                                     additionalConfigs: [.displayDuration(2.0),
                                                                         .showButton(true)]
                )
            } else {
                self?.viewController?.showBannerAgain(withUpdatedText: "actionFailed".localized(),
                                                     additionalConfigs: [.displayDuration(2.0),
                                                                         .showButton(true)]
                )
            }
        })
    }
    
    @objc
    func moveButtonPresed() {
        self.viewController?.router?.showMoveToViewController()
    }
    
    @objc
    func moreButtonPresed() {
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
    
    // MARK: - Undo
    func showUndoBar(text: String) {
        print("show undo bar")
        self.viewController?.undoButton.setTitle(text, for: .normal)
        self.viewController?.undoBar.isHidden = false
        counter = 0
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fadeUndoBar), userInfo: nil, repeats: true)
    }
    
    @objc
    func fadeUndoBar() {
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
        viewController?.undoBar.isHidden = true
        viewController?.undoButton.alpha = 1.0
    }
    
    // MARK: - More Actions
    func initMoreActionsView() {
        viewController?.moreActionsView = Bundle.main.loadNibNamed(k_MoreActionsViewXibName, owner: nil, options: nil)?.first as? MoreActionsView
        viewController?.moreActionsView?.frame = CGRect(x: 0.0, y: 0.0, width: self.viewController!.view.frame.width, height: self.viewController!.view.frame.height)
        viewController?.moreActionsView?.delegate = self.viewController
        
        viewController?.navigationController!.view.addSubview((self.viewController?.moreActionsView)!)
        
        viewController?.moreActionsView?.isHidden = true
    }
    
    func showMoreActionsView() {
        var moreActionsButtonsName: Array<String> = []
        moreActionsButtonsName = self.setupMoreActionsButtons()
        viewController?.moreActionsView?.setup(buttonsNameArray: moreActionsButtonsName)
        let hidden = self.viewController?.moreActionsView?.isHidden
        viewController?.moreActionsView?.isHidden = !hidden!
    }
    
    func setupMoreActionsButtons() -> Array<String> {
        let currentFolder = self.viewController?.currentFolderFilter
        
        let readButton = viewController?.messageIsRead == true ? "markAsUnread".localized() : "markAsRead".localized()

        var moreActionsButtonsName: Array<String> = []
        
        switch currentFolder {
        case MessagesFoldersName.inbox.rawValue:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToArchive".localized()]
        case MessagesFoldersName.draft.rawValue:
            moreActionsButtonsName.removeAll()
        case MessagesFoldersName.sent.rawValue:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToArchive".localized()]
        case MessagesFoldersName.outbox.rawValue:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToArchive".localized(), "moveToInbox".localized()]
        case MessagesFoldersName.starred.rawValue:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToArchive".localized(), "moveToInbox".localized()]
        case MessagesFoldersName.archive.rawValue:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToInbox".localized()]
        case MessagesFoldersName.spam.rawValue:
            moreActionsButtonsName = ["cancel".localized(), "moveToArchive".localized(), "moveToInbox".localized()]
        case MessagesFoldersName.trash.rawValue:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToArchive".localized(), "moveToInbox".localized()]
        default:
            moreActionsButtonsName = ["cancel".localized(), readButton, "moveToArchive".localized(), "moveToInbox".localized()] //for custom folders
        }
        
        return moreActionsButtonsName
    }
    
    func applyMoreAction(_ sender: AnyObject, isButton: Bool) {
        if isButton, let button = sender as? UIButton {
            let title = button.title(for: .normal)
            
            print("title:", title as Any)
            
            switch title {
            case MoreActionsTitles.cancel.rawValue.localized():
                print("cancel btn more actions")
            case MoreActionsTitles.markAsRead.rawValue.localized():
                print("markAsRead btn more actions")
                self.markSelectedMessagesAsRead() 
            case MoreActionsTitles.markAsUnread.rawValue.localized():
                print("markAsUnread btn more actions")
                self.markSelectedMessagesAsRead()
            case MoreActionsTitles.moveToArchive.rawValue.localized():
                print("moveToArchive btn more actions")
                self.moveSelectedMessagesToArchive()
            case MoreActionsTitles.moveToInbox.rawValue.localized():
                print("moveToInbox btn more actions")
                self.moveSelectedMessagesToInbox()
            case MoreActionsTitles.emptyFolder.rawValue.localized():
                print("emptyFolder btn more actions")
            default:
                print("more actions: default")
            }
        }
        self.showMoreActionsView()
    }
    
    func showMoreActionsActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        configureMoreActionsActionSheet(alertController: alertController)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = viewController?.view
            popoverController.sourceRect = CGRect(x: k_popoverSourceRectX, y: k_popoverSourceRectY, width: 0, height: 0)
        }
        viewController?.present(alertController, animated: true, completion: nil)
    }
    
    func configureMoreActionsActionSheet(alertController: UIAlertController) {
        let currentFolder = self.viewController?.currentFolderFilter
        let readButton = viewController?.messageIsRead == true ? "markAsUnread".localized() : "markAsRead".localized()

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
        case MessagesFoldersName.draft.rawValue: break
        case MessagesFoldersName.sent.rawValue:
            actionsList = [readMessageAction, moveToArchiveAction]
        case MessagesFoldersName.outbox.rawValue:
            actionsList = [readMessageAction, moveToArchiveAction, moveToInboxAction]
        case MessagesFoldersName.starred.rawValue:
            actionsList = [readMessageAction, moveToArchiveAction, moveToInboxAction]
        case MessagesFoldersName.archive.rawValue:
            actionsList = [readMessageAction, moveToInboxAction]
        case MessagesFoldersName.spam.rawValue:
            actionsList = [readMessageAction, moveToArchiveAction, moveToInboxAction]
        case MessagesFoldersName.trash.rawValue: break
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
        let undoMessage = read == true ? "undoMarkAsUnread".localized() : "undoMarkAsRead".localized()
        let bannerText = read == true ? "markingAsUnread".localized() : "markingAsRead".localized()
        
        self.interactor?.viewController?.showBanner(withTitle: bannerText, additionalConfigs: [.displayDuration(.infinity), .showButton(false)]
        )
        self.interactor?.markMessageAsRead(message: (self.viewController?.message)!, asRead: !read!, withUndo: undoMessage, onCompletion: { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case true:
                    self?.interactor?.viewController?.router?.backToParentViewController()
                    self?.interactor?.viewController?.showBannerAgain(withUpdatedText: "done".localized(),
                                                         additionalConfigs: [.displayDuration(3.0),
                                                                             .showButton(true)]
                    )
                case false:
                    self?.viewController?.showBannerAgain(withUpdatedText: "actionFailed".localized(),
                                                         additionalConfigs: [.displayDuration(3.0),
                                                                             .showButton(true)]
                    )
                }
            }
        })
    }
    
    func moveSelectedMessagesToArchive() {
        viewController?.showBanner(withTitle: "movingToArchive".localized(),
                                        additionalConfigs: [.displayDuration(.infinity),
                                                            .showButton(false)]
        )
        self.interactor?.moveMessageToArchive(message: (self.viewController?.message)!, withUndo: "undoMoveToArchive".localized(), onCompletion: { [weak self] (isSucceeded) in
            DispatchQueue.main.async {
                if isSucceeded {
                    self?.interactor?.viewController?.router?.backToParentViewController()
                    self?.viewController?.showBannerAgain(withUpdatedText: "done".localized(),
                                                         additionalConfigs: [.displayDuration(3.0),
                                                                             .showButton(true)]
                    )
                } else {
                    self?.viewController?.showBannerAgain(withUpdatedText: "actionFailed".localized(),
                                                         additionalConfigs: [.displayDuration(2.0),
                                                                             .showButton(true)]
                    )
                }
            }
        })
    }
    
    func moveSelectedMessagesToInbox() {
        interactor?.moveMessageToInbox(message: (self.viewController?.message)!, withUndo: "undoMoveToInbox".localized())
    }
}

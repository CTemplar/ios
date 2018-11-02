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
        
    }
    
    @objc func spamButtonPresed() {
        
    }
    
    @objc func moveButtonPresed() {
        
    }
    
    @objc func moreButtonPresed() {
        
    }
}

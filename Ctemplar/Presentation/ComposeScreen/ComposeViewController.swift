//
//  ComposeViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 12.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit
import Foundation
import PKHUD
import AlertHelperKit

class ComposeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var fromView            : UIView!
    @IBOutlet var emailToSectionView  : UIView!
    @IBOutlet var ccToSubSectionView  : UIView!
    @IBOutlet var bccToSubSectionView : UIView!
    @IBOutlet var subjectView         : UIView!
    @IBOutlet var toolBarView         : UIView!
    @IBOutlet var bottomBarView       : UIView!
    
    @IBOutlet var emailFrom           : UILabel!
    @IBOutlet var subjectTextField    : UITextField!
    
    @IBOutlet var messageTextView     : UITextView!
    
    @IBOutlet var emailToTextView     : UITextView!
    @IBOutlet var ccToTextView        : UITextView!
    @IBOutlet var bccToTextView       : UITextView!
    
    @IBOutlet var expandButton        : UIButton!
    
    @IBOutlet var attachmentButton    : UIButton!
    @IBOutlet var encryptedButton     : UIButton!
    @IBOutlet var selfDestructedButton  : UIButton!
    @IBOutlet var delayedDeliveryButton : UIButton!
    @IBOutlet var deadManButton       : UIButton!
    
    @IBOutlet var toViewSectionHeightConstraint          : NSLayoutConstraint!
    @IBOutlet var toViewSubsectionHeightConstraint       : NSLayoutConstraint!
    @IBOutlet var ccViewSubsectionHeightConstraint       : NSLayoutConstraint!
    @IBOutlet var bccViewSubsectionHeightConstraint      : NSLayoutConstraint!
    
    var expandedSectionHeight: CGFloat = 0.0
    
    var presenter   : ComposePresenter?
    var interactor  : ComposeInteractor?
    var router      : ComposeRouter?
    var dataSource  : ComposeDataSource?
    
    var navBarTitle: String = ""
    var senderEmail: String = ""
    var subject    : String = ""
    
    var emailsToArray = Array<String>()
    //var emailToAttributtedSting : NSAttributedString!
    var emailToSting : String = "emailToPrefix".localized()
    
    var ccToArray = Array<String>()
    var ccToSting : String = "ccToPrefix".localized()
    
    var bccToArray = Array<String>()
    var bccToSting : String = "bccToPrefix".localized()
    
    var tapSelectedEmail    : String = ""
    var tapSelectedCcEmail  : String = ""
    var tapSelectedBccEmail : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let configurator = ComposeConfigurator()
        configurator.configure(viewController: self)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.title = navBarTitle
        
        emailToTextView.delegate = self
        emailToTextView.autocorrectionType = .no
        
        ccToTextView.delegate = self
        ccToTextView.autocorrectionType = .no
        
        bccToTextView.delegate = self
        bccToTextView.autocorrectionType = .no        
        
        subjectTextField.delegate = self
        
        ccToSubSectionView.isHidden = true
        bccToSubSectionView.isHidden = true
        
        //temp =========
        emailsToArray.append("test@mega.com")
        emailsToArray.append("dima@tatarinov.com")
        
        for email in emailsToArray {
            self.emailToSting = self.emailToSting + email + " "
        }
        
        self.ccToSting = self.ccToSting  + "test@mega.com" + " " + "dima@tatarinov.com" + " " + "hulygun@mail.net"
        self.bccToSting = self.bccToSting  + "testX@mega.com" + " " + "dmitry@tatarinov.com" + " " + "hulygunHyper@mail.net"
        //========
        
        
        self.presenter?.setupEmailFromSection(emailFromText: self.senderEmail)
        self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
        self.presenter?.setupSubject(subjectText: self.subject)
        
        self.addGesureRecognizers()        
    }
    
    func addGesureRecognizers() {
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnEmailToTextView(_:)))
        tapGesture.delegate = self
        self.emailToTextView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func expandButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.expandButtonPressed()
    }
    
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        
        //sendMail() //temp
        //publicKeyFor(userEmail: "dmitry5@dev.ctemplar.com")
    }
    
    @IBAction func attachmentButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func encryptedButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func selfDestructedButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func delayedDeliveryButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func deadManButtonPressed(_ sender: AnyObject) {
        
    }
        
    //MARK: - textView delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        print("textViewDidBeginEditing")
    
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        //self.setCursorPositionToEnd(textView: textView)
        print("textViewShouldBeginEditing")
        /*
        if textView == self.emailToTextView {
            if self.getCursorPosition(textView: textView) < "emailToPrefix".localized().count {
                self.setCursorPositionToEnd(textView: textView)
            }
            
            if let selectedEmail = self.getCurrentEditingWord(textView: textView) {
                print("selectedEmail", selectedEmail)
                self.tapSelectedEmail = selectedEmail
                self.setupEmailToViewText(emailToText: self.emailToSting)
            }
        }*/
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        //self.setCursorPositionToEnd(textView: textView)
        
        print("textViewDidChange text:", textView.text)
        
        switch textView {
        case self.emailToTextView:
            self.presenter?.setupEmailToSection(emailToText: textView.text, ccToText: self.ccToSting, bccToText: self.bccToSting)
        case self.ccToTextView:
            self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: textView.text, bccToText: self.bccToSting)
        case self.bccToTextView:
            self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: textView.text)
        default:
            break
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        switch textView {
        case self.emailToTextView:
            return (self.interactor?.holdEmailToTextViewInput(textView: self.emailToTextView, shouldChangeTextIn: range, replacementText: text))!
        case self.ccToTextView:
            
            break
        case self.bccToTextView:
            
            break
        default:
            break
        }
        
        return true
    }
    
    //MARK: - textField delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.subject = textField.text!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.subject = textField.text!
        textField.resignFirstResponder()
        
        return true;
    }
    
    //MARK: - other
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false //disable cut/copy
    }
    
    @objc private final func tapOnEmailToTextView(_ tapGesture: UITapGestureRecognizer){
        
        let point = tapGesture.location(in: emailToTextView)
        
        if let selectedEmail = self.interactor?.getWordAtPosition(point, textView: emailToTextView) {
            print("tap selectedEmail:", selectedEmail)
            self.tapSelectedEmail = selectedEmail
            self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
        } else {
            self.tapSelectedEmail = ""
            self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
        }
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        self.tapSelectedEmail = ""
        self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
        view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}

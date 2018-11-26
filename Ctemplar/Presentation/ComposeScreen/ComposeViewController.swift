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

class ComposeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet var fromView            : UIView!
    @IBOutlet var toView              : UIView!
    @IBOutlet var subjectView         : UIView!
    @IBOutlet var toolBarView         : UIView!
    @IBOutlet var bottomBarView       : UIView!
    
    @IBOutlet var messageTextView     : UITextView!
    
    @IBOutlet var emailToTextView     : UITextView!
    
    @IBOutlet var toViewHeightConstraint    : NSLayoutConstraint!
    
    var navBarTitle: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.title = navBarTitle
        
        emailToTextView.delegate = self
        
        setupEmailToSection(emailToText: "To: djhbrhibjhjsjpsjnbsnb toEmailTextField toEmailTextbd djhbrhibjhjsjpsjnbsnb djhbrhibjhjsjpsjnbsn") //djhbrhibjhjsjpsjnbsnb
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        
        //sendMail() //temp
        //publicKeyFor(userEmail: "dmitry5@dev.ctemplar.com")
    }
    
    func setupEmailToSection(emailToText: String) {
        
        self.emailToTextView.backgroundColor = UIColor.yellow//debug
        
        self.setupEmailToViewText(emailToText: emailToText)
        
        let emailToViewHeight = self.setupEmailToViewSize()
        
        toViewHeightConstraint.constant = emailToViewHeight + k_emailToTextViewTopOffset + k_emailToTextViewTopOffset
    }
    
    func setupEmailToViewText(emailToText: String) {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = CGFloat(k_lineSpaceSizeForFromToText)
        
        let font : UIFont = UIFont(name: k_latoRegularFontName, size: 14.0)!
        
        let attributedString = NSMutableAttributedString(string: emailToText, attributes: [
            .font: font,
            .foregroundColor: k_emailToColor,//k_actionMessageColor,
            .kern: 0.0,
            .paragraphStyle: style
            ])
        
        //_ = attributedString.setForgroundColor(textToFind: "To:", color: k_emailToColor)
        
        self.emailToTextView.attributedText = attributedString
    }
    
    func setupEmailToViewSize() -> CGFloat {
        
        let fixedWidth = self.view.frame.width - k_emailToTextViewLeftOffset - k_expandDetailsButtonWidth
              
        self.emailToTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newEmailToTextViewSize = self.emailToTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newEmailToTextViewFrame = self.emailToTextView.frame
        newEmailToTextViewFrame.size = CGSize(width: max(newEmailToTextViewSize.width, fixedWidth), height: newEmailToTextViewSize.height)
        self.emailToTextView.frame = newEmailToTextViewFrame;
        
        return self.emailToTextView.frame.height
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.setupEmailToSection(emailToText: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //print("range location:", range.location, "length:", range.length)
        
        if self.forbidDeletion(range: range) {
            return false
        }
        
        if self.returnPressed(input: text) {
            print("range location:", range.location, "length:", range.length)
            return false
        }
        
        return true
    }
    
    func forbidDeletion(range: NSRange) -> Bool {
        
        if range.location == 3 && range.length == 1 { //forbid to delete "To: "
            return true
        }
        
        return false
    }
    
    func returnPressed(input: String) -> Bool {
        
        if input == "\n" {
            print("need to add as contact and fade rectangle")
            return true
        }
        
        return false
    }
    
    //temp
    
    func sendMail() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let apiService = appDelegate.applicationManager.apiService
        
        let recievers : Array<String> = ["dmitry3@dev.ctemplar.com"]
        
        apiService.createMessage(content: "Non encrypted content for sended message", subject: "Send Test with Sent folder", recieversList: recievers, folder: MessagesFoldersName.sent.rawValue, mailboxID: 44, send: true) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("createMessage value:", value)
                
                
                
            case .failure(let error):
                print("error:", error)
                //AlertHelperKit().showAlert(self.viewController!, title: "Mailboxes Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func publicKeyFor(userEmail: String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let apiService = appDelegate.applicationManager.apiService
        
        let pgpService = appDelegate.applicationManager.pgpService
        
        apiService.publicKeyFor(userEmail: userEmail) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("publicKey value:", value)
                
                let publicKey = value as! String
                print("publicKey:", publicKey)
                
               //pgpService.readPGPKeysFromString(key: publicKey)
                pgpService.extractAndSavePGPKeyFromString(key: publicKey)
                pgpService.getStoredPGPKeys()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self, title: "Public Key Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}

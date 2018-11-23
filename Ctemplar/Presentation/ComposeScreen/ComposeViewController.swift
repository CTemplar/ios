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

protocol InputEmailToTextFieldDelegate {
    func textFieldDidDelete()
}

class InputEmailToTextField: UITextField {
    
    var inputEmailToTextFieldDelegate: InputEmailToTextFieldDelegate?
    
    override func deleteBackward() {
        super.deleteBackward()
        inputEmailToTextFieldDelegate?.textFieldDidDelete()
    }
}

class ComposeViewController: UIViewController, UITextFieldDelegate, InputEmailToTextFieldDelegate {
    
    @IBOutlet var fromView            : UIView!
    @IBOutlet var toView              : UIView!
    @IBOutlet var subjectView         : UIView!
    @IBOutlet var toolBarView         : UIView!
    @IBOutlet var bottomBarView       : UIView!
    
    @IBOutlet var messageTextView     : UITextView!
    
    @IBOutlet var emailToTextView     : UITextView!
    @IBOutlet var toEmailTextField    : InputEmailToTextField!
    
    @IBOutlet var toViewHeightConstraint    : NSLayoutConstraint!
    
    var navBarTitle: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.title = navBarTitle
        
        toEmailTextField.delegate = self
        toEmailTextField.inputEmailToTextFieldDelegate = self
        
        
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
        
        self.emailToTextView.backgroundColor = UIColor.yellow
        
        let width = self.view.frame.width - 16 - 44 //- 16
        self.emailToTextView.frame = CGRect(x: 16, y: 6, width: width, height: 28)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10.0//CGFloat(k_lineSpaceSizeForFromToText) //?
        
        let font : UIFont = UIFont(name: k_latoRegularFontName, size: 14.0)!
        
        let attributedString = NSMutableAttributedString(string: emailToText, attributes: [
            .font: font,
            .foregroundColor: k_actionMessageColor,//UIColor(white: 0.0, alpha: 1.0),
            .kern: 0.0,
            .paragraphStyle: style
            ])
                
        _ = attributedString.setForgroundColor(textToFind: "To:", color: UIColor(white: 158.0 / 255.0, alpha: 1.0))
        
        self.emailToTextView.attributedText = attributedString//NSAttributedString(string: emailToText)
        self.emailToTextView.sizeToFit()
        
        print("self.emailToTextView.frame.height", self.emailToTextView.frame.height)
        
        toViewHeightConstraint.constant = self.emailToTextView.frame.height + 6 + 6//14
        
        //toEmailTextField
    }
    
    @IBAction func emailTyped(_ sender: UITextField) {
        
        print("typed:", sender.text )
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
       
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("end:", textField.text )
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        print("return pressed:", textField.text )
        return true
    }
    
    func textFieldDidDelete() {
        print("delete")
    }
    /*
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        //print("Backspace was pressed!!")
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
     
        let  char = string.cString(using: String.Encoding.utf8)!
        if (char.elementsEqual([0])) {
            print("Backspace was pressed")
        }
        else {
            print("WHAT DOES THE FOX SAY ?\n")
            print(char)
        }
 
        if range.length == 1 {
            print("Backspace was pressed !!")
        }
        
        return true
    }
    
    func keyboardInputShouldDelete(_ textField: UITextField) -> Bool {
        print("Backspace was pressed !")
        return true
    }
    */
    /*
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            print("Backspace was pressed")
        }
        return true
    }*/
    
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

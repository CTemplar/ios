//
//  SecurityViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 06.09.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import AlertHelperKit
import PKHUD

class SecurityViewController: UIViewController {
    
    @IBOutlet var subjectEncryptionSwitch: UISwitch!
    @IBOutlet var contactsEncryptionSwitcher         : UISwitch!
    @IBOutlet var attachmentEncryptionSwitcher       : UISwitch!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var apiService              : APIService?
    var formatterService        : FormatterService?
    var interactor              : SecurityInteractor?
    
    var user = UserMyself()
    
    var encryptSubject      : Bool = false
    var encryptContacts     : Bool = false
    var encryptAttachment   : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.formatterService = appDelegate.applicationManager.formatterService
        self.apiService = appDelegate.applicationManager.apiService
        
        self.interactor = SecurityInteractor()
        self.interactor?.viewController = self
        self.interactor?.apiService = self.apiService
     
        self.setupScreen()
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupScreen() {
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: k_navBar_titleColor]
        
        self.encryptSubject = self.user.settings.isSubjectEncrypted ?? false
        self.subjectEncryptionSwitch.setOn(self.encryptSubject, animated: true)
        
        let currentPlan = self.user.settings.planType ?? ""
        let pendingPayment = self.user.settings.isPendingPayment ?? true
        if currentPlan.lowercased() != "free" && !pendingPayment  {
            self.subjectEncryptionSwitch.isEnabled = true
        }else {
            self.subjectEncryptionSwitch.isEnabled = false
        }
        
        self.encryptContacts = self.user.settings.isContactsEncrypted ?? false
        self.contactsEncryptionSwitcher.setOn(self.encryptContacts, animated: true)
        
        self.encryptAttachment = self.user.settings.isAttachmentsEncrypted ?? false
        self.attachmentEncryptionSwitcher.setOn(self.encryptAttachment, animated: true)        
    }
    
    @IBAction func switchStateDidChange(_ sender: UISwitch) {
        
        switch sender {
        case subjectEncryptionSwitch:
            self.encryptSubject = sender.isOn
            self.interactor?.updateEncryptionSubject(settings: self.user.settings, encryptSubject: self.encryptSubject, encryptContacts: self.encryptContacts, encryptAttachment: self.encryptAttachment)
            break
        case contactsEncryptionSwitcher:
            
            if (sender.isOn == true) {
                self.encryptContacts = true
            } else {
                self.encryptContacts = false
            }
            
            self.showContactEncryptionWarningPopUp(settings: self.user.settings, encryptContacts: self.encryptContacts)
        case attachmentEncryptionSwitcher:
            
            if (sender.isOn == true) {
                self.encryptAttachment = true
            } else {
                self.encryptAttachment = false
            }
            
            self.interactor!.updateEncryptionAttachment(settings: self.user.settings, encryptSubject: self.encryptSubject, encryptContacts: self.encryptContacts, encryptAttachment: self.encryptAttachment)
           
        default:
            break
        }
    }
    
    func showContactEncryptionWarningPopUp(settings: Settings, encryptContacts: Bool) {
        
        var encryptButtonText = ""
        var encryptTitleText = ""
        var encryptMessageText = ""
        
        if encryptContacts {
            encryptButtonText = "encryptButton".localized()
            encryptTitleText = "encryptContactsTitle".localized()
            encryptMessageText = "encryptContacts".localized()
        } else {
            encryptButtonText = "decryptButton".localized()
            encryptTitleText = "decryptContactsTitle".localized()
            encryptMessageText = "decryptContacts".localized()
        }
        
        let params = Parameters(
            title: encryptTitleText,
            message: encryptMessageText,
            cancelButton: "cancelButton".localized(),
            otherButtons: [encryptButtonText]
        )
        
        AlertHelperKit().showAlertWithHandler(self, parameters: params) { buttonIndex in
            switch buttonIndex {
            case 0:
                self.encryptContacts = !self.encryptContacts
                self.contactsEncryptionSwitcher.setOn(self.encryptContacts, animated: true)
                break
            default:
                print("Change Contact Encryption")
                //if encryptContacts {
                self.interactor!.updateEncryptionContacts(settings: settings, encryptSubject: self.encryptSubject, encryptContacts: encryptContacts, encryptAttachment: self.encryptAttachment)
               // } else {
               //     self.startDecryption()
               // }
            }
        }
    }
}

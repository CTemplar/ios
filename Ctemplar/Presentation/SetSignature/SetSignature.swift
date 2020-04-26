//
//  SetSignature.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 25.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import AlertHelperKit
import PKHUD

enum SignatureType {
    case general
    case mobile
}

class SetSignatureViewController: UIViewController {
    
    @IBOutlet var rightBarButtonItem       : UIBarButtonItem!
    @IBOutlet var textFieldView            : UIView!
    @IBOutlet weak var signatureEditorView: RichEditorView!
    @IBOutlet var switcher                 : UISwitch!
    @IBOutlet weak var signatureContainerView_bottom: NSLayoutConstraint!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var signatureType = SignatureType.general
    var userSignature : String = ""
    var apiService      : APIService?
    
    var user = UserMyself()
    var mailbox = Mailbox()
    
    var formatterService        : FormatterService?
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.formatterService = appDelegate.applicationManager.formatterService
        self.apiService = appDelegate.applicationManager.apiService
        
        self.mailbox = (self.apiService?.defaultMailbox(mailboxes: self.user.mailboxesList!))!
        
        self.setupScreen()
        
        self.addNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMessageEditorView()
        signatureEditorView.delegate = self
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        guard signatureType == .mobile else {
            self.updateUserSignature(mailbox: self.mailbox, userSignature: self.userSignature)
            return
        }
        UserDefaults.standard.set(userSignature, forKey: k_mobileSignatureKey)
        UserDefaults.standard.synchronize()
        postUpdateUserSettingsNotification()
        userSignatureWasUpdated()
    }
    
    @IBAction func textTyped(_ sender: UITextField) {
        
        self.userSignature = sender.text!
        self.rigthBarButtonEnabled()
    }
    
    @IBAction func switchStateDidChange(_ sender:UISwitch) {
        
        if (sender.isOn == true) {
            self.textFieldView.isHidden = false
            self.userSignature = self.signatureEditorView.html
            self.setupRightBarButton(show: true)
            self.rigthBarButtonEnabled()
        } else {
            self.textFieldView.isHidden = true
            let value = signatureType == .general ? self.mailbox.signature : UserDefaults.standard.string(forKey: k_mobileSignatureKey)
            if let signature = value {
                if signature.count > 0 {
                    self.userSignature = signatureType == .general ? " " : "" //api doesn't update signature if to send empty "" string
                } else {
                    self.setupRightBarButton(show: false)
                }
            }
        }
    }
    
    func setupScreen() {
        title = (signatureType == .general ? "signature" : "mobileSignature").localized().capitalized
        //self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: k_contactsBarTintColor]
        let value = signatureType == .general ? self.mailbox.signature : UserDefaults.standard.string(forKey: k_mobileSignatureKey)
        if let signature = value {
            if signature.count > 0 {
                self.userSignature = signature
                self.textFieldView.isHidden = false
                self.signatureEditorView.html = signature
                self.switcher.setOn(true, animated: false)
                self.setupRightBarButton(show: true)
            } else {
                self.textFieldView.isHidden = true
                self.switcher.setOn(false, animated: false)
                self.setupRightBarButton(show: false)
            }
        } else {
            self.textFieldView.isHidden = true
            self.switcher.setOn(false, animated: false)
            self.setupRightBarButton(show: false)
        }
    }
    
    func setupRightBarButton(show: Bool) {
        
        if show {
            let saveItem = UIBarButtonItem(title: "saveButton".localized(), style: .plain, target: self, action: #selector(saveButtonPressed))
            saveItem.tintColor = UIColor.darkGray
            self.navigationItem.rightBarButtonItem = saveItem
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func setupMessageEditorView() {
        self.signatureEditorView.inputAccessoryView = toolbar
        self.signatureEditorView.placeholder = "Type message here..."
        
        toolbar.editor = self.signatureEditorView
        toolbar.delegate = self
        
        let clearItem = RichEditorOptionItem(image: nil, title: "Clear") { (toolbar) in
            toolbar.editor?.html = ""
        }
        let doneItem = RichEditorOptionItem(image: nil, title: "Done") { (toolbar) in
            self.signatureEditorView.endEditing(true)
        }
        
        var options = toolbar.options
        options.append(contentsOf: [clearItem, doneItem])
        toolbar.options = options
    }
    
    func rigthBarButtonEnabled() {
        
        if self.validateUserSignature(email: self.userSignature) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func validateUserSignature(email: String) -> Bool {
        
        if (self.formatterService?.validateNameLench(enteredName: email))! {
            return true
        }
        
        return false
    }
    
    func updateUserSignature(mailbox: Mailbox, userSignature: String) {
        
        let mailboxID = mailbox.mailboxID?.description
        let isDefault = mailbox.isDefault
        
        apiService?.updateMailbox(mailboxID: mailboxID!, userSignature: userSignature, displayName: "", isDefault: isDefault!) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("updateUserSignature value:", value)
                self.postUpdateUserSettingsNotification()                
                self.userSignatureWasUpdated()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self, title: "Update Settings Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func postUpdateUserSettingsNotification() {
        let name = signatureType == .general ? k_updateUserSettingsNotificationID : k_reloadViewControllerDataSourceNotificationID
        NotificationCenter.default.post(name: Notification.Name(name), object: nil, userInfo: nil)
    }
    
    func userSignatureWasUpdated() {
        
        let params = Parameters(
            title: "infoTitle".localized(),
            message: "userSignature".localized(),
            cancelButton: "closeButton".localized()
        )
        
        AlertHelperKit().showAlertWithHandler(self, parameters: params) { buttonIndex in
            
            self.cancelButtonPressed(self)
        }
    }
}

extension SetSignatureViewController {
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

extension SetSignatureViewController {
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            signatureContainerView_bottom.constant = keyboardHeight + 20
            
            self.view.layoutIfNeeded()
        }
    }
}

extension SetSignatureViewController: RichEditorDelegate {
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        userSignature = content
        rigthBarButtonEnabled()
    }
}

//MARK: - RichEditor Toolbar Delegate

extension SetSignatureViewController: RichEditorToolbarDelegate {
    
    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple,
            .black,
            .darkGray,
            .brown
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }
    
    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }
    
    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.hasRangeSelection(handler: { (isRangedSelection) in
            if isRangedSelection {
                let alert = UIAlertController(title: "Insert Link", message: nil, preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = "URL (required)"
                }
                alert.addTextField { (textField) in
                    textField.placeholder = "Title"
                }
                alert.addAction(UIAlertAction(title: "Insert", style: .default, handler: { (action) in
                    let textField1 = alert.textFields![0]
                    let textField2 = alert.textFields![1]
                    let url = textField1.text ?? ""
                    if url == "" {
                        return
                    }
                    let title = textField2.text ?? ""
                    toolbar.editor?.insertLink(href: url, text: title)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
    }
}


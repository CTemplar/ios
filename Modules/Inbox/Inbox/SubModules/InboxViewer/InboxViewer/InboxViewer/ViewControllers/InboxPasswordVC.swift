//
//  InboxPasswordVC.swift
//  InboxViewer
//


import UIKit
import Utility
import Networking

public protocol InboxPasswordProtectedEmailDelegate: AnyObject {
    func subjectDecrypt(password: String)
    func backToInbox()
}

class InboxPasswordVC: UIViewController {
    @IBOutlet weak var decryptBtn: UIButton!
    @IBOutlet weak var inboxBtn: UIButton!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var passwordIncorrectStack: UIStackView!
    @IBOutlet weak var passwordHintLbl: UILabel!
    @IBOutlet weak var backView: UIView!
    
    var message:EmailMessage?
    weak var delegate:InboxPasswordProtectedEmailDelegate?
    private let pgpService = UtilityManager.shared.pgpService
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordHintLbl.text =   (self.passwordHintLbl.text ?? "") +  (self.message?.encryption?.passwordHint ?? "")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.textfield.becomeFirstResponder()
        self.navigationController?.navigationBar.isHidden = true
        self.inboxBtn.layer.borderWidth = 2
        self.inboxBtn.layer.borderColor = UIColor(red: 230.0/255, green: 64.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor
        self.inboxBtn.layer.cornerRadius = 8
        self.decryptBtn.layer.borderWidth = 2
        self.decryptBtn.layer.borderColor = UIColor(red: 230.0/255, green: 64.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor
        self.decryptBtn.layer.cornerRadius = 8
        
        self.backView.layer.cornerRadius = 10
        self.backView.layer.borderWidth = 2
        self.backView.layer.borderColor = UIColor(red: 230.0/255, green: 64.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func tapInboxBtn(_ sender: Any) {
        self.delegate?.backToInbox()
    }
     @IBAction func tapDecyptBtn(_ sender: Any) {
        self.getDecryptedContent()

     }

    
    private func getDecryptedContent() {
        if let content = self.message?.content {
            let decryptedContent = pgpService.decryptMessageFromPassword(encryptedContent: content, password: self.textfield.text ?? "")
            if (decryptedContent == "#D_FAILED_ERROR#") {
                self.passwordIncorrectStack.isHidden = false
            }
            else {
                self.delegate?.subjectDecrypt(password: self.textfield.text ?? "")
            }
        }
        else {
            self.delegate?.subjectDecrypt(password:"")
            
        }
        
    }
}

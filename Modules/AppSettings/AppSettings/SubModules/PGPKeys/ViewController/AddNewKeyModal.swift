//
//  AddNewKeyModal.swift
//  AppSettings
//


import UIKit
import Utility
import Networking

enum RadioBtnStatus:Int {
    case ecc = 0
    case rsa
}

 protocol AddNewKeyModalDelegate: AnyObject {
    func addNewKey(keyType: RadioBtnStatus)
    func cancelBtnTapped()
}
class AddNewKeyModal: UIViewController {
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var radioEccBtn: UIButton!
    @IBOutlet weak var radioRSABtn: UIButton!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var emailLbl: UILabel!
    var email = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailLbl.text = email
        // Do any additional setup after loading the view.
    }
    

    weak var delegate:AddNewKeyModalDelegate?
    private let pgpService = UtilityManager.shared.pgpService

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.nextBtn.layer.borderWidth = 2
        self.nextBtn.layer.borderColor = UIColor(red: 230.0/255, green: 64.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor
        self.nextBtn.layer.cornerRadius = 8
        self.cancelBtn.layer.borderWidth = 2
        self.cancelBtn.layer.borderColor = UIColor(red: 230.0/255, green: 64.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor
        self.cancelBtn.layer.cornerRadius = 8
        
        self.backView.layer.cornerRadius = 10
        self.backView.layer.borderWidth = 2
        self.backView.layer.borderColor = UIColor(red: 230.0/255, green: 64.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func tapCancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
     @IBAction func tapNextBtn(_ sender: Any) {
        if (self.radioEccBtn.image(for: .normal) == UIImage(named: "radioRed")) {
            self.delegate?.addNewKey(keyType: RadioBtnStatus.ecc)
        }
        else {
            self.delegate?.addNewKey(keyType: RadioBtnStatus.rsa)
        }
     }

    @IBAction func radioBtnTapped(_ sender: UIButton) {
        switch sender.tag {
        case RadioBtnStatus.ecc.rawValue:
            self.radioEccBtn.isUserInteractionEnabled = false
            self.radioRSABtn.isUserInteractionEnabled = true
            self.radioEccBtn.setImage(UIImage(named: "radioRed"), for: .normal)
            self.radioRSABtn.setImage(UIImage(named: "radioGray"), for: .normal)
        case RadioBtnStatus.rsa.rawValue:
            self.radioEccBtn.isUserInteractionEnabled = true
            self.radioRSABtn.isUserInteractionEnabled = false
            self.radioEccBtn.setImage(UIImage(named: "radioGray"), for: .normal)
            self.radioRSABtn.setImage(UIImage(named: "radioRed"), for: .normal)
        default:
            break
        }
    }
    
//    private func getDecryptedContent() {
//        if let content = self.message?.content {
//            let decryptedContent = pgpService.decryptMessageFromPassword(encryptedContent: content, password: self.textfield.text ?? "")
//            if (decryptedContent == "#D_FAILED_ERROR#") {
//                self.passwordIncorrectStack.isHidden = false
//            }
//            else {
//                self.delegate?.subjectDecrypt(password: self.textfield.text ?? "")
//            }
//        }
//        else {
//            self.delegate?.subjectDecrypt(password:"")
//            
//        }
//        
//    }

}

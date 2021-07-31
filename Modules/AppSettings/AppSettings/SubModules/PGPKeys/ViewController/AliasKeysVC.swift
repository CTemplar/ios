//
//  AliasKeysVC.swift
//  AppSettings
//


import UIKit
import Utility
import Networking

protocol AliasKeyDelegate: AnyObject {
    func getEmail()->String
    func refreshData()
}


class AliasKeysVC: UIViewController {
    @IBOutlet weak var privateKeyDownloadButton: UIButton!
    
    @IBOutlet weak var publicKeyDownloadButton: UIButton!

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var btnStack: UIStackView!
    
    @IBOutlet weak var setPrimaryBtn: UIButton!
    
    var interactor: AliasKeyInteractor?
    var mailbox:Mailbox?
    var email = ""
    var isFromPrimary = false
    var delegate:AliasKeyDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactor = AliasKeyInteractor(parentController: self)
        self.textfield.text = self.mailbox?.fingerprint ?? ""
        self.textfield.isEnabled = false
        
        self.title = email
        if (self.isFromPrimary) {
            self.btnStack.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // parentController?.privateKeyDownloadButton.cornerRadius = 10.0
        // parentController?.privateKeyDownloadButton.shadowColor = k_cellSubTitleTextColor.withAlphaComponent(0.5)
        self.privateKeyDownloadButton.shadowRadius = 10.0
        self.privateKeyDownloadButton.shadowOpacity = 10.0
        self.privateKeyDownloadButton.shadowOffset = CGSize(width: 0.0, height: 10.0)
        self.privateKeyDownloadButton.titleLabel?.lineBreakMode = .byWordWrapping
        self.privateKeyDownloadButton.titleLabel?.textAlignment = .center
        self.privateKeyDownloadButton.setTitle(Strings.PGPKey.privateKeyDownload.localized, for: .normal)
        
        self.publicKeyDownloadButton.cornerRadius = 10.0
        self.publicKeyDownloadButton.shadowColor = k_cellSubTitleTextColor.withAlphaComponent(0.5)
        self.publicKeyDownloadButton.shadowRadius = 10.0
        self.publicKeyDownloadButton.shadowOpacity = 10.0
        self.publicKeyDownloadButton.shadowOffset = CGSize(width: 0.0, height: 10.0)
        self.publicKeyDownloadButton.titleLabel?.lineBreakMode = .byWordWrapping
        self.publicKeyDownloadButton.titleLabel?.textAlignment = .center
        self.publicKeyDownloadButton.setTitle(Strings.PGPKey.publicKeyDownload.localized, for: .normal)
        
    }
    
    @IBAction func onTapDownloadPrivateKey(_ sender: Any) {
        self.downloadPrivateKey()
    }
    
    @IBAction func onTapDownloadPublicKey(_ sender: Any) {
        self.downloadPublicKey()
    }
    
    func downloadPublicKey() {
        
        let filePath = self.createPgpPublicKeyFile(for: self.mailbox ?? Mailbox())
        self.showSharePopup(with: filePath, anchor: self.publicKeyDownloadButton)
        
    }
    
    func downloadPrivateKey() {
        let filePath = self.createPgpPrivateKeyFile(for: self.mailbox ?? Mailbox())
        self.showSharePopup(with: filePath, anchor: self.privateKeyDownloadButton)
    }
    
    func showSharePopup(with filePath: String, anchor: UIView?) {
        let activityController = UIActivityViewController(activityItems: [URL(string: filePath)!], applicationActivities: nil)
        if Device.IS_IPAD {
            activityController.popoverPresentationController?.sourceView = anchor
            activityController.popoverPresentationController?.sourceRect = anchor?.bounds ?? .zero
        }
        self.present(activityController, animated: true, completion: nil)
    }
    
    
    // MARK: - PGP Helpers
    func createPgpPublicKeyFile(for mailbox: Mailbox) -> String{
        let fileName = "\(mailbox.email ?? "")_publicKey_\(mailbox.fingerprint ?? "").txt"
        let fileData = mailbox.publicKey ?? ""
        return createPgpKeyFile(with: fileName, and: fileData)
    }
    
    func createPgpPrivateKeyFile(for mailbox: Mailbox) -> String {
        let fileName = "\(mailbox.email ?? "")_privateKey_\(mailbox.fingerprint ?? "").txt"
        let fileData = mailbox.privateKey ?? ""
        return createPgpKeyFile(with: fileName, and: fileData)
    }
    func updateUI(isFromPrimary:Bool) {
        if (isFromPrimary == true) {
            self.delegate?.refreshData()
            self.navigationController?.popViewController(animated: true)

        }
        else {
//            showBanner(withTitle: Strings.Banner.mailSendingAlert.localized,
//                       additionalConfigs: [.displayDuration(2.0),
//                                           .showButton(false)]
//            )
            self.delegate?.refreshData()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func deleteKey(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete this Key!", preferredStyle: .alert)

        let loginAction = UIAlertAction(title: Strings.Button.okButton.localized, style: .default) { [unowned self] (_) in
            self.interactor!.deleteKeyFromServer()
        }

        alert.addAction(UIAlertAction(title: Strings.Button.cancelButton.localized, style: .cancel))
        loginAction.isEnabled = true
        alert.addAction(loginAction)
        self.present(alert, animated: true)

    }
    
  
    
    @IBAction func setPrimaryBtnTapped(_ sender: Any) {
        self.interactor!.setKeyAsPrimary(model: self.mailbox!)
    }
    private func createPgpKeyFile(with fileName: String, and fileData: String) -> String {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentDirectory.appendingPathComponent(fileName)
        do {
            try fileData.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
            return filePath.absoluteString
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

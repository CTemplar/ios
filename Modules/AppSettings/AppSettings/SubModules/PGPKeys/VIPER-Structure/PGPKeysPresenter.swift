import Foundation
import UIKit
import Utility
import Networking

final class PGPKeysPresenter {
    // MARK: Properties
    private (set) weak var parentController: PGPKeysViewController?
    private (set) var interactor: PGPKeysInteractor?
    private var mailboxList: [Mailbox] = []
    
    // MARK: - Constructor
    init(parentController: PGPKeysViewController?) {
        self.parentController = parentController
        self.interactor = PGPKeysInteractor(parentController: parentController)
    }
    
    // MARK: - Setup
    func setupUI() {
        parentController?.privateKeyDownloadButton.cornerRadius = 10.0
        parentController?.privateKeyDownloadButton.shadowColor = k_cellSubTitleTextColor.withAlphaComponent(0.5)
        parentController?.privateKeyDownloadButton.shadowRadius = 10.0
        parentController?.privateKeyDownloadButton.shadowOpacity = 10.0
        parentController?.privateKeyDownloadButton.shadowOffset = CGSize(width: 0.0, height: 10.0)
        parentController?.privateKeyDownloadButton.titleLabel?.lineBreakMode = .byWordWrapping
        parentController?.privateKeyDownloadButton.titleLabel?.textAlignment = .center
        parentController?.privateKeyDownloadButton.setTitle(Strings.PGPKey.privateKeyDownload.localized, for: .normal)

        parentController?.publicKeyDownloadButton.cornerRadius = 10.0
        parentController?.publicKeyDownloadButton.shadowColor = k_cellSubTitleTextColor.withAlphaComponent(0.5)
        parentController?.publicKeyDownloadButton.shadowRadius = 10.0
        parentController?.publicKeyDownloadButton.shadowOpacity = 10.0
        parentController?.publicKeyDownloadButton.shadowOffset = CGSize(width: 0.0, height: 10.0)
        parentController?.publicKeyDownloadButton.titleLabel?.lineBreakMode = .byWordWrapping
        parentController?.publicKeyDownloadButton.titleLabel?.textAlignment = .center
        parentController?.publicKeyDownloadButton.setTitle(Strings.PGPKey.publicKeyDownload.localized, for: .normal)
        
        parentController?.emailValueTextField.isEnabled = false
        parentController?.emailValueTextField.placeholder = Strings.Contacts.emailAddress.localized
        parentController?.emailTileLabel.text = Strings.Contacts.emailAddress.localized
        
        parentController?.fingerprintTitleLabel.text = Strings.PGPKey.fingerprint.localized
    }
    
    func updateMailbox(_ mailboxList: [Mailbox]) {
        self.mailboxList = mailboxList
        parentController?.downButton.isHidden = mailboxList.count < 2
        let mailBoxObj = mailboxList.first(where: { $0.isDefault == true })
        updateValue(byEmail: mailBoxObj?.email, fingerprint: mailBoxObj?.fingerprint)
    }
    
    func updateValue(byEmail email: String?, fingerprint: String?) {
        parentController?.emailValueTextField.text = email ?? ""
        parentController?.fingerprintValueLabel.text = fingerprint ?? ""
    }
    
    // MARK: - Actions
    func getMailBoxList() {
        interactor?.mailboxList()
    }
    
    func onTapMailbox(from sender: UIButton) {
        let alertController = UIAlertController(title: Strings.Contacts.emailAddress.localized,
                                                message: "",
                                                preferredStyle: .actionSheet)
        mailboxList.forEach({ (mailbox) in
            let action = UIAlertAction(title: mailbox.email ?? "", style: .default) { [unowned self] (_) in
                self.updateValue(byEmail: mailbox.email ?? "", fingerprint: mailbox.fingerprint)
            }
            alertController.addAction(action)
        })
        
        alertController.addAction(.init(title: Strings.Button.cancelButton.localized,
                                        style: .cancel, handler: { (_) in
                                            alertController.dismiss(animated: true, completion: nil)
        }))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceRect = sender.frame
            popoverController.sourceView = parentController?.view
        }
        
        parentController?.present(alertController, animated: true, completion: nil)
    }
    
    func downloadPublicKey() {
        let currentMailId = parentController?.emailValueTextField.text ?? ""
        if let currentMailBox = mailboxList.first(where: { $0.email == currentMailId }),
            let filePath = interactor?.createPgpPublicKeyFile(for: currentMailBox) {
            showSharePopup(with: filePath, anchor: parentController?.publicKeyDownloadButton)
        }
    }
    
    func downloadPrivateKey() {
        let currentMailId = parentController?.emailValueTextField.text ?? ""
        if let currentMailBox = mailboxList.filter({ return $0.email == currentMailId }).first,
            let filePath = interactor?.createPgpPrivateKeyFile(for: currentMailBox) {
            self.showSharePopup(with: filePath, anchor: parentController?.privateKeyDownloadButton)
        }
    }
    
    func showSharePopup(with filePath: String, anchor: UIView?) {
        let activityController = UIActivityViewController(activityItems: [URL(string: filePath)!], applicationActivities: nil)
        if Device.IS_IPAD {
            activityController.popoverPresentationController?.sourceView = anchor
            activityController.popoverPresentationController?.sourceRect = anchor?.bounds ?? .zero
        }
        parentController?.present(activityController, animated: true, completion: nil)
    }
}

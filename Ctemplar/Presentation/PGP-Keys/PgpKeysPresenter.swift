//
//  PgpKeysPresenter.swift
//  Ctemplar
//
//  Created by Majid Hussain on 07/03/2020.
//  Copyright © 2020 CTemplar. All rights reserved.
//

import UIKit
import Networking

class PgpKeysPresenter {
    
    var viewController: PgpKeysViewController!
    var interactor: PgpKeysInteractor!
    
    func setupView() {
        viewController.title = "keys".localized()
        
        viewController.emailAddressTitleLabel.text = "emailAddress".localized()
        viewController.fingerprintTitleLabel.text = "fingerprint".localized()
        
        viewController.publicKeyTitleLabel.text = "publicKey".localized()
        viewController.privateKeyTitleLabel.text = "privateKey".localized()
        
        let underlineAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        viewController.publicKeyDownloadButton.setAttributedTitle(NSAttributedString(string: "publicKeyDownload".localized(), attributes: underlineAttribute), for: .normal)
        viewController.privateKeyDownloadButton.setAttributedTitle(NSAttributedString(string: "privateKeyDownload".localized(), attributes: underlineAttribute), for: .normal)
    }
    
    func addTapGesture() {
        viewController.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureAction(_:)))
        viewController.backgroundView.addGestureRecognizer(viewController.tapGesture!)
    }
    
    func loadMailBoxes() {
        self.interactor.mailboxList()
    }
    
    func setValues(for mailBox: Mailbox? = nil) {
        var currentMailbox: Mailbox = Mailbox()
        if mailBox == nil {
            if let mailBox1 = self.viewController.mailboxList.first(where: { return ($0.isDefault ?? false)
            }) {
                currentMailbox = mailBox1
            }
        }else {
            currentMailbox = mailBox!
        }
        viewController.emailAddressTextField.text = currentMailbox.email
        viewController.fingerprintLabel.text = currentMailbox.fingerprint
    }
    
    func downloadPublicKey() {
        let currentMailId = viewController.emailAddressTextField.text ?? ""
        if let currentMailBox = viewController.mailboxList.filter({ return $0.email == currentMailId }).first {
            let filePath = self.interactor.createPgpPublicKeyFile(for: currentMailBox)
            self.showSharePopup(with: filePath, anchor: viewController.publicKeyDownloadButton)
        }
    }
    
    func downloadPrivateKey() {
        let currentMailId = viewController.emailAddressTextField.text ?? ""
        if let currentMailBox = viewController.mailboxList.filter({ return $0.email == currentMailId }).first {
            let filePath = self.interactor.createPgpPrivateKeyFile(for: currentMailBox)
            self.showSharePopup(with: filePath, anchor: viewController.privateKeyDownloadButton)
        }
    }
    
    func showSharePopup(with filePath: String, anchor: UIView) {
        let activityController = UIActivityViewController(activityItems: [URL(string: filePath)!], applicationActivities: nil)
        if Device.IS_IPAD {
            activityController.popoverPresentationController?.sourceView = anchor
            activityController.popoverPresentationController?.sourceRect = anchor.bounds
        }
        viewController.present(activityController, animated: true, completion: nil)
    }
}

extension PgpKeysPresenter {
    @objc func tapGestureAction(_ tapGesture: UITapGestureRecognizer) {
        self.tableViewSelectionComplete()
    }
}

extension PgpKeysPresenter {
    func textFieldBeginEditing() {
        self.addTapGesture()
        self.viewController.emailsTableView.reloadData()
        var tableViewHeight = CGFloat(self.viewController.mailboxList.count * 40)
        let availableHeight = self.viewController.view.frame.height - self.viewController.emailsTableView.frame.origin.y - 20
        if tableViewHeight > availableHeight {
            tableViewHeight = availableHeight
        }
        self.viewController.emailsTableView_height.constant = tableViewHeight
        UIView.animate(withDuration: 0.2) {
            self.viewController.view.layoutIfNeeded()
        }
    }
    
    func tableViewSelectionComplete() {
        if viewController.tapGesture != nil {
            viewController.backgroundView.removeGestureRecognizer(viewController.tapGesture!)
        }
        self.viewController.emailsTableView_height.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.viewController.view.layoutIfNeeded()
        }
    }
}

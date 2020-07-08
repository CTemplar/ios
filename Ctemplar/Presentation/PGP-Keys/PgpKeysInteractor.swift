//
//  PgpKeysInteractor.swift
//  Ctemplar
//
//  Created by Majid Hussain on 08/03/2020.
//  Copyright © 2020 CTemplar. All rights reserved.
//

import Foundation
import Utility
import Networking

class PgpKeysInteractor {
    
    var apiService      : APIService?
    var viewController  : PgpKeysViewController!
    var presenter       : PgpKeysPresenter!
    
    func mailboxList() {
        Loader.start()
        apiService?.mailboxesList(completionHandler: { [weak self] (result) in
            switch result {
            case .success(let value):
                let mailboxes = value as! Mailboxes
                if let mailboxesList = mailboxes.mailboxesResultsList {
                    self?.viewController.mailboxList = mailboxesList
                    self?.presenter.setValues()
                }
            case .failure(let error):
                print("error:", error)
                self?.viewController.showAlert(with: "Mailboxes Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
            }
            Loader.stop()
        })
    }
    
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
    
    private func createPgpKeyFile(with fileName: String, and fileData: String) -> String {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try fileData.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
            return filePath.absoluteString
        }catch {
            print(error.localizedDescription)
        }
        return ""
    }
}

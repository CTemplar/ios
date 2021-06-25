import Foundation
import UIKit
import Utility
import Networking
import PGPFramework

final class PGPKeysPresenter:NSObject, HashingService {
    // MARK: Properties
    private (set) weak var parentController: PGPKeysViewController?
    private (set) var interactor: PGPKeysInteractor?
    private var mailboxList: [Mailbox] = []
    private var selectedMailbox:Mailbox?
    private var selectedIndex: Int = 0
    private var isFromEditScreen = false
    // MARK: - Constructor
    init(parentController: PGPKeysViewController?) {
        self.parentController = parentController
        self.interactor = PGPKeysInteractor(parentController: parentController)
       
        
    }
    
    // MARK: - Setup
    func setupUI() {
        self.parentController?.tableView.delegate = self
        self.parentController?.tableView.dataSource = self
    }
    
    func updateMailbox(_ mailboxList: [Mailbox]) {
        self.mailboxList = mailboxList
        parentController?.downButton.isHidden = mailboxList.count < 2
        let mailBoxObj = mailboxList.first(where: { $0.isDefault == true })
        updateValue(byEmail: mailBoxObj?.email, fingerprint: mailBoxObj?.fingerprint)
        for (index, selectedMailbox) in self.mailboxList.enumerated() {
            if (selectedMailbox.mailboxID == mailBoxObj?.mailboxID ) {
                self.selectedIndex = index
                DispatchQueue.main.async {
                    self.parentController?.tableView.reloadData()
                }
                break
            }
        }
        self.parentController?.tableView.reloadData()
    }
    
    func updateExtraKeys(_ mailboxList: [Mailbox]) {
        for (index, mailbox) in self.mailboxList.enumerated() {
            let filtered = mailboxList.filter{ $0.mailboxID == mailbox.mailboxID }
            self.mailboxList[index].extraKeys = filtered
        }
        self.parentController?.tableView.reloadData()
        
        if (self.isFromEditScreen == true) {
            self.isFromEditScreen = false
            DispatchQueue.main.async {
                for (index, selectedMailbox) in self.mailboxList.enumerated() {
                    if (selectedMailbox.mailboxID == self.selectedMailbox?.mailboxID ) {
                        self.selectedIndex = index
                        DispatchQueue.main.async {
                            self.parentController?.tableView.reloadData()
                        }
                        break
                    }
                }
                self.updateValue(byEmail: self.selectedMailbox?.email ?? "", fingerprint: self.selectedMailbox?.fingerprint)
            }
        }
    }
    
    func newKeyAdded(_ newMailbox: Mailbox) {
        
        for (index, mailbox) in self.mailboxList.enumerated() {
            if (newMailbox.mailboxID == mailbox.mailboxID) {
                if (self.mailboxList[index].extraKeys == nil) {
                    self.mailboxList[index].extraKeys = [Mailbox]()
                     self.mailboxList[index].extraKeys?.append(newMailbox)
                }
                else {
                    self.mailboxList[index].extraKeys?.append(newMailbox)
                }
                
                break
            }
        }
        self.parentController?.tableView.reloadData()
    }
    
    func updateValue(byEmail email: String?, fingerprint: String?) {
        parentController?.emailValueTextField.text = email ?? ""
      //  parentController?.fingerprintValueLabel.text = fingerprint ?? ""
    }
    
    // MARK: - Actions
    func getMailBoxList(_ isFromEditKey:Bool = false) {
        self.isFromEditScreen = isFromEditKey
        interactor?.mailboxList()
        interactor?.extrakeysList()
        
    }
    
    func onTapMailbox(from sender: UIButton) {
        let alertController = UIAlertController(title: Strings.Contacts.emailAddress.localized,
                                                message: "",
                                                preferredStyle: .actionSheet)
        mailboxList.forEach({ (mailbox) in
            let action = UIAlertAction(title: mailbox.email ?? "", style: .default) { [unowned self] (_) in
                
                for (index, selectedMailbox) in self.mailboxList.enumerated() {
                    if (selectedMailbox.mailboxID == mailbox.mailboxID ) {
                        self.selectedIndex = index
                        self.selectedMailbox = mailbox
                        DispatchQueue.main.async {
                            self.parentController?.tableView.reloadData()
                        }
                        break
                    }
                }
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
    
    
   
    
    func onTapAddKey() {
        let addNewKey: AddNewKeyModal = UIStoryboard(storyboard: .key,
                                                          bundle: Bundle(for: AddNewKeyModal.self)
        ).instantiateViewController()
        if (self.mailboxList.count > 0) {
            addNewKey.email = self.mailboxList[self.selectedIndex].email ?? ""

        }
        addNewKey.delegate = self
       // self.parentController?.view.addSubview(addNewKey.view)
        self.parentController?.present(addNewKey, animated: true, completion: nil)

    }
    
}

extension PGPKeysPresenter: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.mailboxList.count > 0) {
            return (self.mailboxList[self.selectedIndex].extraKeys?.count ?? 0) + 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FingerprintCell.className, for: indexPath) as? FingerprintCell
        else { return UITableViewCell() }
        
        if (indexPath.row == 0) {
            cell.fingerprintLbl.text = self.mailboxList[self.selectedIndex].fingerprint ?? ""
            cell.primaryLabel.isHidden = false
            cell.keyTypeaLbl.text = self.mailboxList[self.selectedIndex].keyType
        }
        else {
            if (indexPath.row > 0) {
                cell.primaryLabel.isHidden = true
                cell.keyTypeaLbl.text = self.mailboxList[self.selectedIndex].extraKeys?[indexPath.row - 1].keyType
                cell.fingerprintLbl.text = self.mailboxList[self.selectedIndex].extraKeys?[indexPath.row - 1].fingerprint ?? ""
            }
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let aliasKeysVC: AliasKeysVC = UIStoryboard(storyboard: .key,
                                                    bundle: Bundle(for: AliasKeysVC.self)
        ).instantiateViewController()
        if(indexPath.row == 0) {
            aliasKeysVC.mailbox = self.mailboxList[self.selectedIndex]
            aliasKeysVC.email = self.mailboxList[self.selectedIndex].email ?? ""
            aliasKeysVC.isFromPrimary = true
        }
        else {
            if (indexPath.row > 0) {
                aliasKeysVC.mailbox = self.mailboxList[self.selectedIndex].extraKeys?[indexPath.row - 1]
                aliasKeysVC.email = self.mailboxList[self.selectedIndex].email ?? ""
            }
            
        }
        aliasKeysVC.delegate = self.parentController
        self.parentController?.navigationController?.pushViewController(aliasKeysVC, animated: true)
    }
}

extension PGPKeysPresenter: AddNewKeyModalDelegate {
   
    
    func addNewKey(keyType: RadioBtnStatus) {
        self.parentController?.dismiss(animated: true, completion: nil)
        Loader.start()
        if (keyType == RadioBtnStatus.ecc) {
            let pgpService = UtilityManager.shared.pgpService
            let password = pgpService.getPasswordFromKeychain()
            let keyModel = PGPEncryption().generateNewKeyModel(userName: self.mailboxList[self.selectedIndex].email ?? "", password: password)
            let trimmedUsername = self.interactor?.getTrimmedUserName(name: self.mailboxList[0].email ?? "") ?? ""
            
            generateHashedPassword(for: trimmedUsername, password: password) { [weak self] (result) in
                guard let self = self else {
                    Loader.stop()
                    return
                }
                
                guard let value = try? result.get() else {
                    Loader.stop()
                    return
                }
                let newKeyModel = NewKeyModel(password: value, privateKey: keyModel.privateKey ?? "", publicKey: keyModel.publicKey ?? "", fingerprint: keyModel.fingerprint ?? "", mailboxID: self.mailboxList[self.selectedIndex].mailboxID!, keyType: "ECC")

            self.interactor?.saveNewkeyOnServer(model: newKeyModel)
            }
        }
        else {
            let pgpService = UtilityManager.shared.pgpService
            let password = pgpService.getPasswordFromKeychain()
            let keyModel = PGPEncryption().generateNewKeyModel(userName: self.mailboxList[self.selectedIndex].email ?? "", password: password, "rsa")
            print(keyModel)
            let trimmedUsername = self.interactor?.getTrimmedUserName(name: self.mailboxList[0].email ?? "") ?? ""
            
            generateHashedPassword(for: trimmedUsername, password: password) { [weak self] (result) in
                guard let self = self else {
                    Loader.stop()
                    return
                }
                
                guard let value = try? result.get() else {
                    Loader.stop()
                    return
                }
                let newKeyModel = NewKeyModel(password: value, privateKey: keyModel.privateKey ?? "", publicKey: keyModel.publicKey ?? "", fingerprint: keyModel.fingerprint ?? "", mailboxID: self.mailboxList[self.selectedIndex].mailboxID!, keyType: "RSA4096")

            self.interactor?.saveNewkeyOnServer(model: newKeyModel)
        }
       }
    }
    
    func getEmail()->String {
        return self.mailboxList[0].email ?? ""
    }

    func cancelBtnTapped() {
        
    }
        
}

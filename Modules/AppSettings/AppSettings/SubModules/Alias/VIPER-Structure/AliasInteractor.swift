//
//  AliasInteractor.swift
//  AppSettings

import Foundation
import Utility
import Networking
import Signup
import UIKit

class AliasInteractor:NSObject, HashingService {
    // MARK: Properties
    private let apiService = NetworkManager.shared.apiService
    private (set) weak var parentController: AliasController?
    private var mailboxes: [Mailbox] = []
     weak var tableView: UITableView?
    
    // MARK: - Constructor
    init(parentController: AliasController?) {
        self.parentController = parentController
    }
    
    // MARK: - API Calls
    func mailboxList() {
        Loader.start()
        apiService.mailboxesList(completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch result {
                case .success(let value):
                    let mailboxes = value as! Mailboxes
                    if let mailboxesList = mailboxes.mailboxesResultsList {
                       // self?.parentController?.presenter?.updateMailbox(mailboxesList)
                    }
                case .failure(let error):
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        })
    }
    
    
     func setupTableView() {
        //tableView?.tableFooterView = UIView()
        
       // tableView?.estimatedRowHeight = 60.0
        //tableView?.rowHeight = UITableView.automaticDimension
        
        tableView?.delegate = self
        tableView?.dataSource = self
        
        tableView?.register(UINib(nibName: AliasCell.className, bundle: Bundle(for: AliasCell.self)), forCellReuseIdentifier: AliasCell.className)

        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemBackground
        tableView?.backgroundView = backgroundView
        self.fetchMailboxList()
    }
    
    func addBtnTapped() {
        Loader.start()
        let password = UtilityManager.shared.keychainService.getPassword()

        generateCryptoInfo(for: parentController?.userNameTxtField.text ?? "", password: password) { [weak self] in
            guard let info = try? $0.get() else {
                DPrint(" error in generating alias keys")
                return
            }
            let emailId = (self?.parentController?.userNameTxtField.text)! + (self?.parentController?.lastNameLbl.text)!
            let model = AliasModel(email: emailId, privateKey: info.userPgpKey.privateKey, publicKey: info.userPgpKey.publicKey, fingerprint: info.userPgpKey.fingerprint)
            self?.apiService.createAlias(model: model) { [weak self] (result) in
                DispatchQueue.main.async {
                    Loader.stop()
                    switch result {
                    case .success(let value):
                        if let mailbox = value as? Mailbox {
                            self?.mailboxes.append(mailbox)
                            DispatchQueue.main.async {
                                self?.parentController?.userNameTxtField.text = ""
                                self?.parentController?.defaultUIState()
                                self?.tableView?.reloadData()
                            }
                           
                        }
                    case .failure(let error):
                        DPrint(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc
    private func statusBtnTapped(_ sender: UIButton) {
        Loader.start()
        guard self.mailboxes.count > sender.tag
        else {
            return
        }
        let model = self.mailboxes[sender.tag]
        var isEnableStatus = false
        if (model.isEnabled == true) {
            isEnableStatus = false
        }
        else {
            isEnableStatus = true
        }
        
        
        self.apiService.updateMailboxStatus(mailboxID: String(model.mailboxID!), isEnable: isEnableStatus) { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch result {
                case .success(let value):
                    if let mailbox = value as? Mailbox {
                        guard self?.mailboxes.count ?? 0 > sender.tag
                        else {
                            return
                        }
                        
                        self?.mailboxes.remove(at: sender.tag)
                        self?.mailboxes.insert(mailbox, at: sender.tag)
                        self?.mailboxes.append(mailbox)
                        DispatchQueue.main.async {
                            self?.tableView?.reloadData()
                        }
                       
                    }
                case .failure(let error):
                    DPrint(error.localizedDescription)
                }
            }
        }
    }
    
    func checkUser(userName: String) {
        if self.parentController?.presenter?.formatter?.validateNameLench(enteredName: userName) == false {
            parentController?.presenter?.updateUserExistanceText(by: .unAvailable)
            return
        }
        
        NetworkManager.shared.networkService.checkUser(name: userName) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let value):
                    DPrint("checkUser success value:", value)
                    self.parentController?.presenter?.updateUserExistanceText(by: value.exists ? .unAvailable : .available)
                case .failure(let error):
                    DPrint("checkUser error:", error)
                    self.parentController?.presenter?.updateUserExistanceText(by: .unAvailable)
                }
            }
        }
    }
    
  private  func fetchMailboxList() {
    Loader.start()
        apiService.mailboxesList( completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch result {
                case .success(let value):
                    if let mailboxes = value as? Mailboxes {
                        let mailboxList = mailboxes.mailboxesResultsList ?? []
                        self?.mailboxes = mailboxList.sorted { $0.isDefault ?? false && !($1.isDefault ?? false) }
                       
                        DispatchQueue.main.async {
                            self?.tableView?.reloadData()
                        }
                       
                    }
                case .failure(let error):
                    DPrint(error.localizedDescription)
                }
            }
        })
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource
extension AliasInteractor: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mailboxes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.configureCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Cell Configuration
     func configureCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(withIdentifier: AliasCell.className,
                                                        for: indexPath) as? AliasCell
        else {
            return UITableViewCell()
        }
        let model = self.mailboxes[indexPath.row]
        cell.configure(model: model)
        cell.statusBtn.tag = indexPath.row
        cell.statusBtn.addTarget(self, action: #selector(statusBtnTapped(_:)), for: .touchUpInside)
        return cell
    }
    
}

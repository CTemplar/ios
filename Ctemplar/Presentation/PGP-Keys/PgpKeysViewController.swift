//
//  PgpKeysViewController.swift
//  Ctemplar
//
//  Created by Majid Hussain on 07/03/2020.
//  Copyright © 2020 CTemplar. All rights reserved.
//

import UIKit

class PgpKeysViewController: UIViewController {

    @IBOutlet var backgroundView: UIView!
    @IBOutlet var emailAddressTitleLabel: UILabel!
    @IBOutlet var emailAddressTextField: UITextField!
    @IBOutlet var fingerprintTitleLabel: UILabel!
    @IBOutlet var fingerprintLabel: UILabel!
    @IBOutlet var publicKeyTitleLabel: UILabel!
    @IBOutlet var publicKeyDownloadButton: UIButton!
    @IBOutlet var privateKeyTitleLabel: UILabel!
    @IBOutlet var privateKeyDownloadButton: UIButton!
    @IBOutlet var emailsTableView: UITableView!
    @IBOutlet var emailsTableView_height: NSLayoutConstraint!
    
    var tapGesture: UITapGestureRecognizer?
    
    var presenter: PgpKeysPresenter?
    var dataSource: PgpKeysDatasource?
    var mailboxList: [Mailbox] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let configurator = PgpKeysConfigurator()
        configurator.configure(with: self)
        
        presenter?.setupView()
        presenter?.loadMailBoxes()
        
        dataSource?.initWith(tableView: emailsTableView)
    }
    
    @IBAction func publicKeyDownloadButtonPressed(_ sender: UIButton) {
        self.presenter?.downloadPublicKey()
    }
    
    @IBAction func privateKeyDownloadButtonPressed(_ sender: UIButton) {
        self.presenter?.downloadPrivateKey()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
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

extension PgpKeysViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.presenter?.textFieldBeginEditing()
        return false
    }
}

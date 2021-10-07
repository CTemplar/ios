//
//  ComposeVC.swift
//  AppSettings
//


import UIKit
import Networking

class ComposeVC: UIViewController {
    private (set) var presenter: ComposerPresenter?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    var user = UserMyself()
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ComposerPresenter(parentController: self, user: self.user)
        self.navigationController?.navigationBar.isHidden = true
        self.presenter?.setupUI()
        // Do any additional setup after loading the view.
    }
    // MARK: - Constructor
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        self.presenter?.saveBtnClicked()
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.navigationBar.isHidden = false
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

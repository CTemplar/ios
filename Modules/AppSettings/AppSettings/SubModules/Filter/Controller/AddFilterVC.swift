//
//  AddFilterVC.swift
//  AppSettings
//


import UIKit
import Networking

protocol AddFilterDelegate {
    func updateFilter(filter: Filter)
    func refreshFilter()
}

class AddFilterVC: UIViewController {
    private (set) var presenter: AddFilterPresenter?
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var folderModel:[Folder]?
    var delegate:AddFilterDelegate?
    var isForEdit = false
    var filterModel:Filter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = AddFilterPresenter(parentController: self)
        // Do any additional setup after loading the view.
        self.presenter?.folderModel = folderModel
        self.presenter?.setupUI()
    }
    
    @IBAction func submitBtnTapped(_ sender: Any) {
        self.presenter?.submitBtnClicked()
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tableView.reloadData()
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

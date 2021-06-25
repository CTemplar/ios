//
//  FilterVC.swift
//  AppSettings
//


import UIKit

class FilterVC: UIViewController {
    private (set) var presenter: FilterPresenter?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFilterBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = FilterPresenter(parentController: self)
        self.navigationController?.navigationBar.isHidden = true
        self.presenter?.setupUI()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addFilterBtnTapped(_ sender: Any) {
        let addFilter: AddFilterVC = UIStoryboard(storyboard: .filter,
                                                    bundle: Bundle(for: AddFilterVC.self)
        ).instantiateViewController()
        addFilter.folderModel = self.presenter?.folderModel
        addFilter.delegate = self.presenter
        self.present(addFilter, animated: true, completion: nil)
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


//
//  SubscribeController.swift
//  Sub
//


import Foundation
import Networking
import Utility
import Inbox
import UIKit
import SideMenu

class SubscribeController: UIViewController {
    var selectedProduct = ""
    var recieptArray = [LatestReciept]()
    var rightBarButtonItem: UIBarButtonItem!
    var isPurchasing = false
    let apiService = NetworkManager.shared.apiService
    var selectedPlan_Index = 0
    var selectedPlan : Plan?
    var features = [[String:Any]]()
    var monthPrice = "",yearPrice = "",transactionID = "",payType = "monthly"
    var recieptBase64 = ""
    var monthlyProduct_Identifier : RegisteredPurchase?,yearlyProduct_Identifier : RegisteredPurchase?
    @IBOutlet var subscribeTable : UITableView!{
        didSet{
            subscribeTable.dataSource = self
            subscribeTable.delegate = self
            subscribeTable.tableFooterView = UIView()
            subscribeTable.separatorStyle = .none
        }
    }
    private var user = UserMyself()
    var imageArray = [UIImage(systemName: "mail"),UIImage(systemName: "paperclip"),UIImage(systemName: "briefcase"),UIImage(named: "alias"),UIImage(named: "domain"),UIImage(systemName: "folder")]

    override func viewDidLoad() {
        super.viewDidLoad()

        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setTitle("Restore Purchase", for: .normal)
        btnLeftMenu.titleLabel?.font = AppFont.heavy.size(14)
        btnLeftMenu.setTitleColor(k_cellTitleTextColor, for: .normal)
        btnLeftMenu.addTarget(self, action: #selector(self.restorePurchase), for: UIControl.Event.touchUpInside)
        rightBarButtonItem = UIBarButtonItem(customView: btnLeftMenu)
         self.navigationItem.rightBarButtonItem = rightBarButtonItem
 
        
        let dummyViewHeight = CGFloat(40)
        self.subscribeTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.subscribeTable.bounds.size.width, height: dummyViewHeight))
        self.subscribeTable.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        
        navigationItem.title = selectedPlan?.name
        
        
        subscribeTable.register(UINib(nibName: PurchaseCell.className,
                                  bundle: Bundle(for: PurchaseCell.self)),
                            forCellReuseIdentifier: PurchaseCell.className)
        subscribeTable.register(UINib(nibName: FeatureCell.className,
                                  bundle: Bundle(for: FeatureCell.self)),
                            forCellReuseIdentifier: FeatureCell.className)
        subscribeTable.register(UINib(nibName: HeaderCell.className,
                                  bundle: Bundle(for: HeaderCell.self)),
                            forCellReuseIdentifier: HeaderCell.className)
        subscribeTable.register(UINib(nibName: MorePlanCell.className,
                                  bundle: Bundle(for: MorePlanCell.self)),
                            forCellReuseIdentifier: MorePlanCell.className)

        getInAppDetails()
        // Do any additional setup after loading the view.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.subscribeTable.reloadData()
    }
}

extension SubscribeController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return features.count
        }else{
            return (self.selectedPlan?.name == "FREE") ? 0 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            return self.header(tableview: tableView, path: indexPath)
        }
       else if indexPath.section == 1{
            return self.setFeatures(tableview: tableView, path: indexPath)
        }else if indexPath.section == 2{
            return self.viewMore(tableview: tableView, path: indexPath)
        }else{
            return self.setPurchase(tableview: tableView, path: indexPath)
        }
    }
    func viewMore(tableview : UITableView,path : IndexPath) -> UITableViewCell{
        guard let cell = tableview.dequeueReusableCell(withIdentifier: MorePlanCell.CellIdentifier, for: path) as? MorePlanCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        return cell
    }
    func header(tableview : UITableView,path : IndexPath) -> UITableViewCell{
        guard let cell = tableview.dequeueReusableCell(withIdentifier: HeaderCell.CellIdentifier, for: path) as? HeaderCell else {
            return UITableViewCell()
        }
        //cell.planLBL.text = selectedPlan?.name.uppercased()
        //cell.featureLBL.text = (cell.planLBL.text == "") ? "" : "TOP FEATURES"
        cell.set(plan: selectedPlan?.name ?? "")

        return cell
    }
    func setPurchase(tableview : UITableView,path : IndexPath) -> UITableViewCell{
        guard let cell = tableview.dequeueReusableCell(withIdentifier: PurchaseCell.CellIdentifier, for: path) as? PurchaseCell else {
            return UITableViewCell()
        }

        cell.delegate = self
        cell.selectedIndex = selectedPlan_Index
        cell.monthPriceLBL.text = monthPrice
        cell.yearlPriceLBL.text = yearPrice
        cell.continueBTN.setTitle("Continue", for: .normal)
        if isPurchasing{
            cell.continueBTN.showLoading()
        }else{
        }
        
        cell.setSelection()
        
        return cell
    }
    func setFeatures(tableview : UITableView,path : IndexPath) -> UITableViewCell{
        guard let cell = tableview.dequeueReusableCell(withIdentifier: FeatureCell.CellIdentifier, for: path) as? FeatureCell else {
            return UITableViewCell()
        }
        let obj = features[path.row]
        cell.leadingConstraint.constant = 20
        cell.trailingConstraint.constant = 20
        cell.featureName_LBl.attributedText = obj["name"] as? NSAttributedString
        cell.checkImgView.image = imageArray[path.row]
        cell.checkImgView.setImageColor(color: (self.traitCollection.userInterfaceStyle == .dark) ? UIColor.white : k_redColor)
        
        return cell
    }

    
}
extension SubscribeController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 3 && self.selectedPlan?.name != "FREE"){
            return 40
        }
        else if section == 1{
            return 0
        }
        else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let holderView = UIView(frame: CGRect(x: 20, y: 0, width: viewHeader.frame.size.width - 40, height: 40))
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: viewHeader.frame.size.width - 32, height: 40))
        lbl.text = (section == 1) ? "features".uppercased() : "Choose your plan".uppercased()
        lbl.font = AppFont.heavy.size(14)
        lbl.textColor = k_cellSubTitleTextColor
        holderView.backgroundColor = .clear
        holderView.addSubview(lbl)
        viewHeader.addSubview(holderView)
        viewHeader.backgroundColor = .clear

        return viewHeader
    }
}

extension SubscribeController {
    func purchaseMonthly(){
        self.payType = "monthly"
        self.selectedProduct = self.monthlyProduct_Identifier?.identifier ?? ""
        IAPHelper.main.purchase(self.monthlyProduct_Identifier!, atomically: false) {
            self.getUpdatedReceipt()
        } failure: { alert in
            self.present(alert, animated: true) {
                self.isPurchasing = false
                self.reloadPurchaseButton()
            }
        }
    }
    
    func purchaseYearly(){
        self.payType = "annually"
        self.selectedProduct = self.yearlyProduct_Identifier?.identifier ?? ""
        IAPHelper.main.purchase(self.yearlyProduct_Identifier!, atomically: false) {
            self.getUpdatedReceipt()
        } failure: { alert in
            self.present(alert, animated: true) {
                self.isPurchasing = false
                self.reloadPurchaseButton()
            }
        }
    }
}

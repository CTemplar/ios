//
//  SubscriptionListController.swift
//  Sub
//


import UIKit
import Networking
import Utility
import Inbox
import UIKit
import SideMenu
import Foundation

class SubscriptionListController: UIViewController,LeftBarButtonItemConfigurable {
    var leftBarButtonItem: UIBarButtonItem!
    private let apiService = NetworkManager.shared.apiService
    private (set) var router: SubscribeRouter?
    private (set) var presenter: SubscriptionPresenter?
    private (set) var user = UserMyself()
    var sectionArray = ["","Top Features","","Our Other Plans"]
    var featureArray = [[String:Any]]()
    var plans = [Plan]()
    var planName = "FREE"
    var existingPlan : Plan?
    var imageArray = [UIImage(systemName: "mail"),UIImage(systemName: "paperclip"),UIImage(systemName: "briefcase"),UIImage(named: "alias"),UIImage(named: "domain"),UIImage(systemName: "folder")]

    @IBOutlet var subscriptionTable : UITableView!{
        didSet{
            subscriptionTable.dataSource = self
            subscriptionTable.delegate = self
            subscriptionTable.tableFooterView = UIView()
            subscriptionTable.separatorStyle = .none
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updatePurchase),
                                               name: .purchaseUpdateAlertNotificationID,
                                               object: nil)
        
        

        let btnLeftMenu: UIButton = UIButton()
        let colorTint = (self.traitCollection.userInterfaceStyle == .dark) ? UIColor(named: "redColor") : UIColor(named: "navButtonTintColor")
        btnLeftMenu.setImage(UIImage(named: "MenuButton")?.withRenderingMode(.alwaysTemplate), for: UIControl.State.normal)
        btnLeftMenu.tintColor = colorTint
        btnLeftMenu.addTarget(self, action: #selector(self.menuButtonPressed), for: UIControl.Event.touchUpInside)
        leftBarButtonItem = UIBarButtonItem(customView: btnLeftMenu)
         self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        registerCells()
        getPlans()
    }
    func setup(user: UserMyself) {
        self.user = user
    }
    func setup(router: SubscribeRouter?) {
        self.router = router
    }
    func setup(presenter: SubscriptionPresenter) {
        self.presenter = presenter
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        setupLeftBarButtonItems()
    }
    @objc func updatePurchase(){
        Loader.start()
        self.apiService.userMyself { [weak self] (result) in
            Loader.stop()
            switch(result) {
            case .success(let value):
                guard let userMyself = value as? UserMyself else {
                    return
                }
                NotificationCenter.default.post(name: .updateUserDataNotificationID, object: value)
                self?.setup(user: userMyself)
                self?.getPlans()
            case .failure(let error):
                DPrint("error:", error)
            }
        }
    }
    
    // MARK: - Setup
    func setupNavigationBar() {
        title = Strings.Menu.subscriptions.localized.capitalized
    }
    
    func setupLeftBarButtonItems() {
        navigationController?.prefersLargeTitle = true
        navigationItem.largeTitleDisplayMode = .automatic
        presenter?.setupNavigationLeftItem()
    }
    
    
    // MARK: - Orientation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if (Device.IS_IPAD) {
            presenter?.setupNavigationLeftItem()
        }
    }
    
    func registerCells(){
        let dummyViewHeight = CGFloat(40)
        self.subscriptionTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.subscriptionTable.bounds.size.width, height: dummyViewHeight))
        self.subscriptionTable.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        
 
        
        subscriptionTable.register(UINib(nibName: PlanCell.className,
                                  bundle: Bundle(for: PlanCell.self)),
                            forCellReuseIdentifier: PlanCell.className)
        subscriptionTable.register(UINib(nibName: MorePlanCell.className,
                                  bundle: Bundle(for: MorePlanCell.self)),
                            forCellReuseIdentifier: MorePlanCell.className)
        subscriptionTable.register(UINib(nibName: FeatureCell.className,
                                  bundle: Bundle(for: FeatureCell.self)),
                            forCellReuseIdentifier: FeatureCell.className)
        subscriptionTable.register(UINib(nibName: HeaderCell.className,
                                  bundle: Bundle(for: HeaderCell.self)),
                            forCellReuseIdentifier: HeaderCell.className)
    }
    
    func getPlans(){
        let bundle = Bundle(for: type(of: self))
        if let path = bundle.path(forResource: "plans", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .uncached)
                let decoder = JSONDecoder()
                
                do {
                    let jsonPlans = try decoder.decode(Array<Plan>.self, from: data)
                    self.plans = jsonPlans
                    self.setData()
                } catch {
                    print(error)
                }
            } catch {
                // handle error
            }
        }
    }
    
    func attributedString(allText : String,boldText : String) -> NSAttributedString{
        let mainString = allText
        let stringToColor = boldText
        let range = (mainString as NSString).range(of: stringToColor)
        
        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: AppFont.heavy.size(16), range: range)
        return mutableAttributedString
    }
    
    func setData(){
        self.featureArray.removeAll()
        self.planName = user.settings.planType ?? ""
        if self.planName != "FREE"{
            if let index:Int = self.plans.firstIndex(where: {$0.name == "FREE"}) {
                self.plans.remove(at: index)
            }
        }
        let currentPlans = self.plans.filter { $0.name == self.planName }
        if currentPlans.count > 0{
            let myPlan = currentPlans[0]
            existingPlan = myPlan
            let unlimited_folders = myPlan.unlimited_folders
            let msg = myPlan.messages_per_day
            let mails = (msg == -1) ? "Unlimited" : "\(msg)"
            let messages = "Sending limits \(mails) emails per day"
            let attachment = "Attachment limits \(myPlan.attachment_upload_limit) MB"
            let storage = "Storage \(myPlan.storage) GB"
            let aliases = "Alias \(myPlan.aliases)"
            let domain = "Custom domain \(myPlan.domain_count)"
            var folders = "Folder NA"
            if unlimited_folders{
                folders = "Folders Unlimited"
            }
            
            let messagesAttrib = self.attributedString(allText: messages, boldText: "\(mails)")
            let attachmentAttrib =  self.attributedString(allText: attachment, boldText: "\(myPlan.attachment_upload_limit)")
            let storageAttrib =  self.attributedString(allText: storage, boldText: "\(myPlan.storage)")
            let aliasesAttrib =  self.attributedString(allText: aliases, boldText: "\(myPlan.aliases)")
            let domainAttrib =  self.attributedString(allText: domain, boldText: "\(myPlan.domain_count)")
            let foldersAttrib =  self.attributedString(allText: folders, boldText: "")
            
            
            self.featureArray.append(["name":messagesAttrib,"image":"mails"])
            self.featureArray.append(["name":attachmentAttrib,"image":"attachments"])
            self.featureArray.append(["name":storageAttrib,"image":"storage"])
            self.featureArray.append(["name":aliasesAttrib,"image":"alias"])
            self.featureArray.append(["name":domainAttrib,"image":"domain"])
            self.featureArray.append(["name":foldersAttrib,"image":"folders"])
        }
        
        
        let filteredPlans = self.plans.filter { $0.name != self.planName }
        self.plans = filteredPlans
        
        self.subscriptionTable.reloadData()
    }
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        self.router?.showInboxSideMenu()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.subscriptionTable.reloadData()
    }
}

extension SubscriptionListController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return featureArray.count
        case 2:
            return 1
        case 3:
            return plans.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            return self.header(tableview: tableView, path: indexPath)
        }else if indexPath.section == 1{
            return self.setFeatures(tableview: tableView, path: indexPath)
        }else if indexPath.section == 2{
            return self.viewMore(tableview: tableView, path: indexPath)
        }else{
            return self.setPlans(tableview: tableView, path: indexPath)
        }
    }
    func header(tableview : UITableView,path : IndexPath) -> UITableViewCell{
        guard let cell = tableview.dequeueReusableCell(withIdentifier: HeaderCell.CellIdentifier, for: path) as? HeaderCell else {
            return UITableViewCell()
        }
        //cell.planLBL.text = self.planName
        //cell.featureLBL.text = (cell.planLBL.text == "") ? "" : "TOP FEATURES"
        cell.set(plan: self.planName)
        
        return cell
    }
    func viewMore(tableview : UITableView,path : IndexPath) -> UITableViewCell{
        guard let cell = tableview.dequeueReusableCell(withIdentifier: MorePlanCell.CellIdentifier, for: path) as? MorePlanCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        return cell
    }
    func setPlans(tableview : UITableView,path : IndexPath) -> UITableViewCell{
        guard let cell = tableview.dequeueReusableCell(withIdentifier: PlanCell.CellIdentifier, for: path) as? PlanCell else {
            return UITableViewCell()
        }
        cell.planName.text = self.plans[path.row].name.uppercased()
        
        return cell
    }
    func setFeatures(tableview : UITableView,path : IndexPath) -> UITableViewCell{
        guard let cell = tableview.dequeueReusableCell(withIdentifier: FeatureCell.CellIdentifier, for: path) as? FeatureCell else {
            return UITableViewCell()
        }
        let obj = featureArray[path.row]
        cell.leadingConstraint.constant = 20
        cell.trailingConstraint.constant = 20
        cell.featureName_LBl.attributedText = obj["name"] as? NSAttributedString
        cell.checkImgView.image = imageArray[path.row]
        cell.checkImgView.setImageColor(color: (self.traitCollection.userInterfaceStyle == .dark) ? UIColor.white : k_redColor)
        
        return cell
    }
}
extension SubscriptionListController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == sectionArray.count - 1{
            let bundle = Bundle(for: SubscribeController.self)
            let storyboard = UIStoryboard(name: "Subscription", bundle: bundle)
            let controller = storyboard.instantiateViewController(withIdentifier: "SubscribeController") as! SubscribeController
            let myPlan = plans[indexPath.row]
            let unlimited_folders = myPlan.unlimited_folders
            let messages = "Sending limits \(myPlan.messages_per_day) emails per day"
            let attachment = "Attachment limits \(myPlan.attachment_upload_limit) MB"
            let storage = "Storage \(myPlan.storage) GB"
            let aliases = "Alias \(myPlan.aliases)"
            let domain = "Custom domain \(myPlan.domain_count)"
            var folders = "Folder NA"
            if unlimited_folders{
                folders = "Folders Unlimited"
            }
            
            let messagesAttrib = self.attributedString(allText: messages, boldText: "\(myPlan.messages_per_day)")
            let attachmentAttrib =  self.attributedString(allText: attachment, boldText: "\(myPlan.attachment_upload_limit)")
            let storageAttrib =  self.attributedString(allText: storage, boldText: "\(myPlan.storage)")
            let aliasesAttrib =  self.attributedString(allText: aliases, boldText: "\(myPlan.aliases)")
            let domainAttrib =  self.attributedString(allText: domain, boldText: "\(myPlan.domain_count)")
            let foldersAttrib =  self.attributedString(allText: folders, boldText: "")
            
            
            var features = [[String : Any]]()
            features.append(["name":messagesAttrib,"image":"mails"])
            features.append(["name":attachmentAttrib,"image":"attachments"])
            features.append(["name":storageAttrib,"image":"storage"])
            features.append(["name":aliasesAttrib,"image":"alias"])
            features.append(["name":domainAttrib,"image":"domain"])
            features.append(["name":foldersAttrib,"image":"folders"])
            controller.selectedPlan = myPlan
            controller.features = features
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || section == 0 || section == 1{
            return 0
        }else{
            return 40
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let holderView = UIView(frame: CGRect(x: 0, y: 0, width: viewHeader.frame.size.width - 40, height: 40))
        let lbl = UILabel(frame: CGRect(x: 16, y: 0, width: viewHeader.frame.size.width - 32, height: 40))
        lbl.text = sectionArray[section].uppercased()
        lbl.font = UIFont(name: "Avenir-Heavy", size: 16)
        lbl.textColor = k_cellTitleTextColor
        holderView.backgroundColor = .clear
        holderView.addSubview(lbl)
        viewHeader.addSubview(holderView)
        viewHeader.backgroundColor = .clear
        if section == 2 || section == 0 || section == 1{
            return nil
        }else{
          return viewHeader
        }
    }
}

extension SubscriptionListController : MoreDelegate{
    func moreTapped() {
        let bundle = Bundle(for: SubscribeController.self)
        let storyboard = UIStoryboard(name: "Subscription", bundle: bundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "SubscriptionDetailController") as! SubscriptionDetailController
        let navController = UINavigationController(rootViewController: controller)
        controller.selectedPlan = existingPlan
        self.present(navController, animated: true)
    }
}

enum SubscriptionPlanType: String {
    case prime = "PRIME"
    case free = "FREE"
    case knight = "KNIGHT"
    case marshall = "MARSHALL"
    case paragon = "PARAGON"
    case champion = "CHAMPION"
}


//
//  SubscriptionDetailController.swift
//  Sub
//


import UIKit
import Utility

class SubscriptionDetailController: UIViewController {
    
    var packages = [[String:Any]]()
    var selectedPlan : Plan?
    var sectionArray = ["Package","Features"]
    var featureArray = [PlanFeature]()

    @IBOutlet var featureTable : UITableView!{
        didSet{
            featureTable.dataSource = self
            featureTable.delegate = self
            featureTable.tableFooterView = UIView()
            featureTable.separatorStyle = .none
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedPlan?.name
        setPackages()
        featureTable.register(UINib(nibName: FeatureCell.className,
                                  bundle: Bundle(for: FeatureCell.self)),
                            forCellReuseIdentifier: FeatureCell.className)
        featureTable.register(UINib(nibName: PackageCell.className,
                                  bundle: Bundle(for: PackageCell.self)),
                            forCellReuseIdentifier: PackageCell.className)
    
        let dummyViewHeight = CGFloat(40)
        self.featureTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.featureTable.bounds.size.width, height: dummyViewHeight))
        self.featureTable.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
   
        // Do any additional setup after loading the view.
    }
    
    func setPackages(){
        let msg = (selectedPlan?.messages_per_day ?? 0)
        let mails = (msg == -1) ? "Unlimited" : "\(msg)"
        packages.append(["name":"Sending limits ","image":"mails","value":"\(mails)/day"])
        let upload = "\(selectedPlan?.attachment_upload_limit ?? 0)/MB"
        packages.append(["name":"Attachment limits","image":"attachments","value":upload])
        let storage = "\(selectedPlan?.storage ?? 0)/GB"
        packages.append(["name":"Storage","image":"storage","value":storage])
        packages.append(["name":"Aliases","image":"alias","value":selectedPlan?.aliases ?? 0])
        packages.append(["name":"Custom domain","image":"domain","value":selectedPlan?.custom_domains ?? 0])
        packages.append(["name":"Folders","image":"folders","value":"Unlimited"])
       
        setFeatures()
    }
    
    func setFeatures(){
        if let plan = selectedPlan{
            let mirror = Mirror(reflecting: plan)
            for child in mirror.children  {
                if let chk = child.value as? Bool{
                    if let keyStr = child.label{
                        self.featureArray.append(PlanFeature.init(nameStr: keyStr.replacingOccurrences(of: "_", with: " ").uppercased(), check: chk))
                    }
                }
            }
        }
        featureTable.reloadData()
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

extension SubscriptionDetailController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return packages.count
        }else{
            return 12
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
           return self.setPackages(tableview: tableView, path: indexPath)
        }else{
            return self.setFeatures(tableview: tableView, path: indexPath)
        }
    }
    
    func setPackages(tableview : UITableView,path : IndexPath) -> UITableViewCell{
        guard let cell = tableview.dequeueReusableCell(withIdentifier: PackageCell.CellIdentifier, for: path) as? PackageCell else {
            return UITableViewCell()
         }
        
        let dic = self.packages[path.row]
        let name = dic["name"]
        let value = dic["value"]
        cell.packageName_LBl.text = name  as? String
        cell.packageDesc_LBL.text = "\(value!)"
        
        return cell
    }
    
    func setFeatures(tableview : UITableView,path : IndexPath) -> UITableViewCell{
        guard let cell = tableview.dequeueReusableCell(withIdentifier: FeatureCell.CellIdentifier, for: path) as? FeatureCell else {
            return UITableViewCell()
        }
        let feature = self.featureArray[path.row]
        
        var checkImage = UIImage()
        var checkColor = UIColor.red
        if feature.available {
            checkImage = UIImage(named: "check") ?? UIImage()
            checkColor =  k_jpgColor
        }else{
            checkImage = UIImage(named: "cancel") ?? UIImage()
            checkColor = k_redColor
        }
        
        cell.checkImgView.image = checkImage
        cell.checkImgView.backgroundColor = .clear
        cell.checkImgView.setImageColor(color: checkColor)
        cell.leadingConstraint.constant = 20
        cell.trailingConstraint.constant = 20
        cell.featureName_LBl.text = feature.name.capitalizingFirstLetter()
        
        return cell
    }

}

extension SubscriptionDetailController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let lbl = UILabel(frame: CGRect(x: 20, y: 0, width: viewHeader.frame.size.width - 40, height: 40))
        lbl.text = sectionArray[section]
        lbl.font = UIFont(name: "Avenir-Heavy", size: 16)
        lbl.textColor = k_cellSubTitleTextColor
        viewHeader.backgroundColor = .clear
        viewHeader.addSubview(lbl)
      
        return viewHeader
    }
}

struct PlanFeature {
    var name = ""
    var available = false
    
    init(nameStr : String , check : Bool) {
        self.name = nameStr
        self.available = check
    }
}

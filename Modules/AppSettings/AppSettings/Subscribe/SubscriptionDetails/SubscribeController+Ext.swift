//
//  SubscribeController+Ext.swift
//  AppSettings
//


import UIKit
import Utility

extension SubscribeController{
    
    func getInAppDetails(){
        if let plan = self.selectedPlan{
            let planType = SubscriptionPlanType.init(rawValue: plan.name)
            switch planType {
            case .free: break;
            case .prime:
                monthlyProduct_Identifier = RegisteredPurchase.monthlyPrime
                yearlyProduct_Identifier = RegisteredPurchase.yearlyPrime
            case .knight:
                monthlyProduct_Identifier = RegisteredPurchase.monthlyKnight
                yearlyProduct_Identifier = RegisteredPurchase.yearlyKnight
            case .marshall:
                monthlyProduct_Identifier = RegisteredPurchase.monthlyMarshall
                yearlyProduct_Identifier = RegisteredPurchase.yearlyMarshall
            case .paragon:
                break;
            case .champion:
                monthlyProduct_Identifier = RegisteredPurchase.monthlyChampion
                yearlyProduct_Identifier = RegisteredPurchase.yearlyChampion
            case .none:
                break;
            }
        }
        self.getProductInfo()
    }
    
    //    j3{X%JR8
    func getProductInfo(){
        SwiftyStoreKit.retrieveProductsInfo([monthlyProduct_Identifier?.identifier ?? "" , yearlyProduct_Identifier?.identifier ?? ""]) { result in
            let products = result.retrievedProducts
            for product in products{
                let priceString = product.localizedPrice!
                let productIdentifier = product.productIdentifier
                if productIdentifier == self.monthlyProduct_Identifier?.identifier{
                    self.monthPrice = priceString
                }
                if productIdentifier == self.yearlyProduct_Identifier?.identifier{
                    self.yearPrice = priceString
                }
            }
            self.subscribeTable.reloadData()
        }
    }
    func getUpdatedReceipt(){
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
            case .success(let receiptData):
                self.recieptBase64 = receiptData.base64EncodedString(options: [])
                self.notifyServerForPurchase()
            case .error(let error):
                print("Fetch receipt failed: \(error)")
            }
        }
    }
    
    func validateReciept(){
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: IAPHelper.main.sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let receipt):
                    if let latest_receipt_info = receipt["latest_receipt_info"] as? [[String : Any]]{
                        for dic in latest_receipt_info{
                            let trans = LatestReciept.init(data: dic)
                            self.recieptArray.append(trans)
                        }
                        
                        let filteredArray =  self.recieptArray.filter { $0.product_id == self.selectedProduct }

                        if filteredArray.count > 0{
                            let filteredArray2 = filteredArray.max(by: { $0.expireDate < $1.expireDate })
//                            print(filteredArray)
                            print("++++++++++++")
                            print(filteredArray2)

                            if filteredArray2 != nil{
                                self.transactionID = filteredArray2?.transaction_id ?? "NA"
                                self.notifyServerForPurchase()
                            }
                        }
                    }
                case .error(let error):
                    self.isPurchasing = false
                    self.reloadPurchaseButton()
                    self.showAlert(with: "Failed to validate purchase", message: error.localizedDescription, buttonTitle: "OK")
                }
            }
        }
    }

    func notifyServerForPurchase(){
        let model = PurchaseModel(customer_identifier: self.recieptBase64, payment_identifier: self.transactionID, payment_method: "apple", payment_type: self.payType, plan_type: self.selectedPlan?.name.uppercased() ?? "")
        self.apiService.subscribePlan(model: model) {(result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let status):
                    if let passed = status as? Bool{
                        if passed{
                            self.navigationController?.popViewController {
                                NotificationCenter.default.post(.init(name: .purchaseUpdateAlertNotificationID))
                            }
                        }
                    }
                    self.isPurchasing = false
                    self.reloadPurchaseButton()
                case .failure(let error):
                    self.isPurchasing = false
                    self.reloadPurchaseButton()
                    self.showAlert(with: "Failed to purchase", message: error.localizedDescription, buttonTitle: "OK")
                }
            }
        }
    }
}

extension SubscribeController : PurchaseCellDelegate{
    @objc func restorePurchase() {
        IAPHelper.main.restorePurchases { alert, success in
            self.present(alert, animated: true, completion: nil)
        }
    }
    func purchaseAction() {
        isPurchasing = true

        if selectedPlan_Index == 0{
            self.purchaseMonthly()
        }else{
            self.purchaseYearly()
        }
        
        self.reloadPurchaseButton()
    }
    
    func reloadPurchaseButton(){
        self.view.isUserInteractionEnabled = (self.isPurchasing == true) ? false : true
        let numberOfSections = self.subscribeTable.numberOfSections - 1
        self.subscribeTable.beginUpdates()
        self.subscribeTable.reloadSections([numberOfSections], with: .none)
        self.subscribeTable.endUpdates()
    }
    
    func monthly_Tapped(cell :PurchaseCell) {
        if isPurchasing{
            return
        }
        selectedPlan_Index = 0
        cell.selectedIndex = selectedPlan_Index
        cell.setSelection()
    }
    
    func yearly_Tapped(cell :PurchaseCell) {
        if isPurchasing{
            return
        }
        selectedPlan_Index = 1
        cell.selectedIndex = selectedPlan_Index
        cell.setSelection()
    }
}

extension SubscribeController : MoreDelegate{
    func moreTapped() {
        let bundle = Bundle(for: SubscribeController.self)
        let storyboard = UIStoryboard(name: "Subscription", bundle: bundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "SubscriptionDetailController") as! SubscriptionDetailController
        let navController = UINavigationController(rootViewController: controller)
        controller.selectedPlan = selectedPlan
        self.present(navController, animated: true)
    }
}

struct LatestReciept {
    var expires_date_ms : TimeInterval = 0
    var product_id = ""
    var expireDate = Date()
    var transaction_id = ""
    var web_order_line_item_id = ""
    
    init(data : [String : Any]) {
        print(data)
        if let intervalTime = data["expires_date_ms"] as? String{
            self.expires_date_ms = intervalTime.convertToTimeInterval()
        }
        if let product = data["product_id"] as? String{
            self.product_id = product
        }
        if let transactionid = data["transaction_id"] as? String{
            self.transaction_id = transactionid
        }
        if let webid = data["web_order_line_item_id"] as? String{
            self.web_order_line_item_id = webid
        }
        let epochTime = TimeInterval(self.expires_date_ms) / 1000
        self.expireDate = Date(timeIntervalSince1970: epochTime)
    }
    
}
extension String {
    func convertToTimeInterval() -> TimeInterval {
        guard self != "" else {
            return 0
        }

        var interval:Double = 0

        let parts = self.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }

        return interval
    }
}

//
//  IAPHelper.swift
//  Calligraphy
//
//  Created by Edgar Sia on 9/28/20.
//  Copyright © 2020 Dhiren. All rights reserved.
//

import Foundation
import UIKit

enum RegisteredPurchase: String, CaseIterable {
    case monthlyChampion
    case yearlyChampion
    case monthlyMarshall
    case yearlyMarshall
    case monthlyKnight
    case yearlyKnight
    case monthlyPrime
    case yearlyPrime

    var identifier: String {
        switch self {
        //Champion
        case .monthlyChampion:
            return "com.ctemplar.corp.iosapp.championmonthly"
        case .yearlyChampion:
            return "com.ctemplar.corp.iosapp.championyearly"

        //Marshall
        case .monthlyMarshall:
            return "com.ctemplar.corp.iosapp.marshallmonthly"
        case .yearlyMarshall:
            return "com.ctemplar.corp.iosapp.marshallyearly"
            
        //Knight
        case .monthlyKnight:
            return "com.ctemplar.corp.iosapp.knightmonthly"
        case .yearlyKnight:
            return "com.ctemplar.corp.iosapp.knightyearly"
            
        //Prime
        case .monthlyPrime:
            return "com.ctemplar.corp.iosapp.primemonthly"
        case .yearlyPrime:
            return "com.ctemplar.corp.iosapp.primeyearly"
        }
    }
}

@objc class IAPHelper: NSObject {
    let sharedSecret = "66121040aed7442b88a9c73fb8613c51"
    @objc public static let main = IAPHelper.init()
    private var iap: [String: DefaultsKey<Bool>] = [:]
    
    override init() {
        super.init()
        RegisteredPurchase.allCases.forEach({
            iap[$0.rawValue] = DefaultsKey<Bool>.init($0.rawValue, defaultValue: false)
        })
    }
}

// MARK: - Functions
extension IAPHelper {
    
    // Apple recommends to register a transaction observer as soon as the app starts
    @objc func registerTransactionObserver() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break // do nothing
                }
            }
        }
    }
    
    func purchase(_ purchase: RegisteredPurchase, atomically: Bool, success: @escaping ()->Void, failure: @escaping (UIAlertController)->Void) {
        
        SwiftyStoreKit.purchaseProduct(purchase.identifier, atomically: atomically) { result in
            if case .success(let purchase) = result {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            switch result {
            case .success(let purchased):
                print("Purchase Success: \(purchased.productId)")
                if let key = self.iap[purchase.rawValue] {
                    Defaults[key: key] = true
                }

                success()
            case .error(let error):
                print("Purchase Failed: \(error)")
                var title: String;
                var message: String;
                switch error.code {
                case .unknown: title = "Purchase failed"; message = error.localizedDescription
                case .clientInvalid: // client is not allowed to issue the request, etc.
                    title = "Purchase failed"; message = "Not allowed to make the payment"
                case .paymentCancelled: // user cancelled the request, etc.
                    title = "Purchase canceled"; message = "You canceled the purchase"
                case .paymentInvalid: // purchase identifier was invalid, etc.
                    title = "Purchase failed"; message = "The purchase identifier was invalid"
                case .paymentNotAllowed: // this device is not allowed to make the payment
                    title = "Purchase failed"; message = "The device is not allowed to make the payment"
                case .storeProductNotAvailable: // Product is not available in the current storefront
                    title = "Purchase failed"; message = "The product is not available in the current storefront"
                case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                    title = "Purchase failed"; message = "Access to cloud service information is not allowed"
                case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                    title = "Purchase failed"; message = "Could not connect to the network"
                case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                    title = "Purchase failed"; message = "Cloud service was revoked"
                default:
                    title = "Purchase failed"; message = error.localizedDescription
                }
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                failure(alertController)
            }
        }
    }
    @objc func restorePurchases(completion: @escaping (UIAlertController,Bool)->Void) {
        var restored = false
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            for purchase in results.restoredPurchases {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                } else if purchase.needsFinishTransaction {
                    // Deliver content from server, then:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            var title: String; var message: String
            if results.restoreFailedPurchases.count > 0 {
                restored = false
                print("Restore Failed: \(results.restoreFailedPurchases)")
                title = "Restore failed"; message = "Unknown error. Please contact support"
            } else if results.restoredPurchases.count > 0 {
                restored = true
                print("Restore Success: \(results.restoredPurchases)")
                for restoredPruchase in results.restoredPurchases {
                    print("Purchase Restored: \(restoredPruchase.productId)")
                    if let key = self.iap[restoredPruchase.productId] {
                        Defaults[key: key] = true
                    }
                }
                title = "Purchases Restored"; message = "All purchases have been restored"
            } else {
                restored = false
                print("Nothing to Restore")
                title = "Nothing to restore"; message = "No previous purchases were found"
            }
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            completion(alertController,restored)
        }
        
    }
    
    
    @objc func purchaseMonthlyMarshal(success: @escaping ()->Void, failure: @escaping (UIAlertController)->Void) {
        self.purchase(.monthlyMarshall, atomically: true, success: success, failure: failure)
    }
    
    @objc func purchaseYearlyMarshal(success: @escaping ()->Void, failure: @escaping (UIAlertController)->Void) {
        self.purchase(.yearlyMarshall, atomically: true, success: success, failure: failure)
    }
    
    @objc func purchaseYearlyPrime(success: @escaping ()->Void, failure: @escaping (UIAlertController)->Void) {
        self.purchase(.yearlyPrime, atomically: true, success: success, failure: failure)
    }
    
    @objc func purchaseMonthlyPrime(success: @escaping ()->Void, failure: @escaping (UIAlertController)->Void) {
        self.purchase(.monthlyPrime, atomically: true, success: success, failure: failure)
    }
    
    @objc func purchaseMonthlyKnight(success: @escaping ()->Void, failure: @escaping (UIAlertController)->Void) {
        self.purchase(.monthlyKnight, atomically: true, success: success, failure: failure)
    }
    
    @objc func purchaseYearlyKnight(success: @escaping ()->Void, failure: @escaping (UIAlertController)->Void) {
        self.purchase(.yearlyKnight, atomically: true, success: success, failure: failure)
    }
    @objc func purchaseMonthlyChampion(success: @escaping ()->Void, failure: @escaping (UIAlertController)->Void) {
        self.purchase(.monthlyChampion, atomically: true, success: success, failure: failure)
    }
    
    @objc func purchaseYearlyChampion(success: @escaping ()->Void, failure: @escaping (UIAlertController)->Void) {
        self.purchase(.yearlyChampion, atomically: true, success: success, failure: failure)
    }

}

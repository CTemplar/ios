//
//  Settings.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 21.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct Settings: Hashable {
    
    var allocatedStorage : Int? = nil
    var autoresponder : Bool? = nil
    var defaultFont : String? = nil
    var displayName : String? = nil
    var domainCount : Int? = nil
    var emailCount : Int? = nil
    var emailsPerPage : Int? = nil
    var embedContent : Bool? = nil
    var fromAddress : String? = nil
    var settingsID : Int? = nil
    var isPendingPayment : Bool? = nil
    var language : String? = nil
    var newsletter: Bool? = nil
    var recoveryEmail : String? = nil
    var recurrenceBilling : Int? = nil
    var redeemCode : String? = nil
    var saveContacts : Bool? = nil
    var showSnippets: Bool? = nil
    var stripeCustomerCode : String? = nil
    var timeZone : String? = nil
    var usedStorage: Int? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.allocatedStorage = dictionary["allocated_storage"] as? Int
        self.autoresponder = dictionary["autoresponder"] as? Bool
        self.defaultFont = dictionary["default_font"] as? String
        self.displayName = dictionary["display_name"] as? String
        self.domainCount = dictionary["domain_count"] as? Int
        self.emailCount = dictionary["email_count"] as? Int
        self.emailsPerPage = dictionary["emails_per_page"] as? Int
        self.embedContent = dictionary["embed_content"] as? Bool
        self.fromAddress = dictionary["from_address"] as? String
        self.settingsID = dictionary["id"] as? Int
        self.isPendingPayment = dictionary["is_pending_payment"] as? Bool
        self.language = dictionary["language"] as? String
        self.newsletter = dictionary["newsletter"] as? Bool
        self.recoveryEmail = dictionary["recovery_email"] as? String
        self.recurrenceBilling = dictionary["recurrence_billing"] as? Int
        self.redeemCode = dictionary["redeem_code"] as? String
        self.saveContacts = dictionary["save_contacts"] as? Bool
        self.showSnippets = dictionary["show_snippets"] as? Bool
        self.stripeCustomerCode = dictionary["stripe_customer_code"] as? String
        self.timeZone = dictionary["timezone"] as? String
        self.usedStorage = dictionary["used_storage"] as? Int
    }
}


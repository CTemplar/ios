//
//  UserResult.swift
//  Ctemplar
//
//  Created by Roman Kharchenko on 2019-12-18.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Foundation

struct MyselfResult: Codable {
    let username: String
    let id: Int
    let isPrime: Bool
    let joinedDate: String
    let paymentTransaction: PaymentTransaction?
    let abuseWarningCount: Int
    let autoresponder: String?
    let customFolders: [CustomFolder]
    let mailboxes: [MailboxR]
    let settings: UserSettings
    
    private enum CodingKeys: String, CodingKey {
        case username, id, autoresponder, mailboxes, settings
        case isPrime = "is_prime"
        case joinedDate = "joined_date"
        case paymentTransaction = "payment_transaction"
        case abuseWarningCount = "abuse_warning_count"
        case customFolders = "custom_folders"
    }
}

struct PaymentTransaction: Codable {
    let amount: String
    let billingCycleEnds: String
    let created: String
    let currency: String
    let id: Int
    let isRefund: Bool
    let paymentMethod: String
    let paymentType: String
    let stripePlan: String
    let transactionId: String
    
    private enum CodingKeys: String, CodingKey {
        case amount, id, created, currency
        case billingCycleEnds = "billing_cycle_ends"
        case isRefund = "is_refund"
        case paymentMethod = "payment_method"
        case paymentType = "payment_type"
        case stripePlan = "stripe_plan"
        case transactionId = "transaction_id"
    }
}

struct UserSettings: Codable {
    let id: Int
    let language: String
    let newsletter: Bool
    let timezone: String?
    let allocatedStorage: Int
    let antiPhishingPhrase: String?
    let attachmentSizeError: String?
    let attachmentSizeLimit: Int
    let defaultFont: String?
    let displayName: String
    let domainCount: Int
    let e2eeNonct: Bool
    let emailCount: Int
    let emailsPerPage: Int
    let embedContent: Bool
    let enableForwarding: Bool
    let enableTFA: Bool
    let forwardingAddress: String?
    let fromAddress: String?
    let isAntiPhishingEnabled: Bool
    let isAttachmentsEncrypted: Bool
    let is_contactsEncrypted: Bool
    let isHtmlDisabled: Bool
    let isPendingPayment: Bool
    let isSubjectEncrypted: Bool
    let notificationEmail: String?
    let planType: String
    let recoveryEmail: String?
    let recurrenceBilling: Bool
    let redeemСode: String?
    let saveContacts: Bool
    let showSnippets: Bool
    let stripeCustomerCode: String?
    let usedStorage: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, language, newsletter, timezone
        case allocatedStorage = "allocated_storage"
        case antiPhishingPhrase = "anti_phishing_phrase"
        case attachmentSizeError = "attachment_size_error"
        case attachmentSizeLimit = "attachment_size_limit"
        case defaultFont = "default_font"
        case displayName = "display_name"
        case domainCount = "domain_count"
        case e2eeNonct = "e2ee_nonct"
        case emailCount = "email_count"
        case emailsPerPage = "emails_per_page"
        case embedContent = "embed_content"
        case enableForwarding = "enable_forwarding"
        case enableTFA = "enable_2fa"
        case forwardingAddress = "forwarding_address"
        case fromAddress = "from_address"
        case isAntiPhishingEnabled = "is_anti_phishing_enabled"
        case isAttachmentsEncrypted = "is_attachments_encrypted"
        case is_contactsEncrypted = "is_contacts_encrypted"
        case isHtmlDisabled = "is_html_disabled"
        case isPendingPayment = "is_pending_payment"
        case isSubjectEncrypted = "is_subject_encrypted"
        case notificationEmail = "notification_email"
        case planType = "plan_type"
        case recoveryEmail = "recovery_email"
        case recurrenceBilling = "recurrence_billing"
        case redeemСode = "redeem_code"
        case saveContacts = "save_contacts"
        case showSnippets = "show_snippets"
        case stripeCustomerCode = "stripe_customer_code"
        case usedStorage = "used_storage"
    }
}


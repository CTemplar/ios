//
//  UserResult.swift
//  Ctemplar
//
//  Created by Roman Kharchenko on 2019-12-18.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Foundation

public struct MyselfResult: Codable {
    public let username: String
    public let id: Int
    public let isPrime: Bool
    public let joinedDate: String
    public let paymentTransaction: PaymentTransaction?
    public let abuseWarningCount: Int
    public let autoresponder: String?
    public let customFolders: [CustomFolder]
    public let mailboxes: [MailboxR]
    public let settings: UserSettings
    
    private enum CodingKeys: String, CodingKey {
        case username, id, autoresponder, mailboxes, settings
        case isPrime = "is_prime"
        case joinedDate = "joined_date"
        case paymentTransaction = "payment_transaction"
        case abuseWarningCount = "abuse_warning_count"
        case customFolders = "custom_folders"
    }
}

public struct PaymentTransaction: Codable {
    public let amount: String
    public let billingCycleEnds: String
    public let created: String
    public let currency: String
    public let id: Int
    public let isRefund: Bool
    public let paymentMethod: String
    public let paymentType: String
    public let stripePlan: String
    public let transactionId: String
    
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

public struct UserSettings: Codable {
    public let id: Int
    public let language: String
    public let newsletter: Bool
    public let timezone: String?
    public let allocatedStorage: Int
    public let antiPhishingPhrase: String?
    public let attachmentSizeError: String?
    public let attachmentSizeLimit: Int
    public let defaultFont: String?
    public let displayName: String
    public let domainCount: Int
    public let e2eeNonct: Bool
    public let emailCount: Int
    public let emailsPerPage: Int
    public let embedContent: Bool
    public let enableForwarding: Bool
    public let enableTFA: Bool
    public let forwardingAddress: String?
    public let fromAddress: String?
    public let isAntiPhishingEnabled: Bool
    public let isAttachmentsEncrypted: Bool
    public let is_contactsEncrypted: Bool
    public let isHtmlDisabled: Bool
    public let isPendingPayment: Bool
    public let isSubjectEncrypted: Bool
    public let notificationEmail: String?
    public let planType: String
    public let recoveryEmail: String?
    public let recurrenceBilling: Bool
    public let redeemСode: String?
    public let saveContacts: Bool
    public let showSnippets: Bool
    public let stripeCustomerCode: String?
    public let usedStorage: Int
    
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


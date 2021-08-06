import Foundation

public struct Settings: Hashable {
    // MARK: Properties
    public private (set) var allocatedStorage: Int?
    public private (set) var autoresponder: Bool?
    public private (set) var defaultFont: String?
    public private (set) var displayName: String?
    public private (set) var domainCount: Int?
    public private (set) var emailCount: Int?
    public private (set) var emailsPerPage: Int?
    public private (set) var embedContent: Bool?
    public private (set) var fromAddress: String?
    public private (set) var settingsID: Int?
    public private (set) var isPendingPayment: Bool?
    public private (set) var isAttachmentsEncrypted: Bool?
    public private (set) var isSubjectEncrypted: Bool?
    public private (set) var isContactsEncrypted: Bool?
    public private (set) var language: String?
    public private (set) var newsletter: Bool?
    public private (set) var recoveryEmail: String?
    public private (set) var recurrenceBilling: Int?
    public private (set) var redeemCode: String?
    public private (set) var saveContacts: Bool?
    public private (set) var showSnippets: Bool?
    public private (set) var stripeCustomerCode: String?
    public private (set) var timeZone: String?
    public private (set) var usedStorage: Int?
    
    public private (set) var antiPhishingPhrase: String?
    public private (set) var attachmentSizeError: String?
    public private (set) var attachmentSizeLimit: Int?
    public private (set) var e2eeNonct: Bool?
    public private (set) var enable2fa: Bool?
    public private (set) var enableForwarding: Bool?
    public private (set) var forwardingAddress: String?
    public private (set) var isAntiPhishingEnabled: Bool?
    public private (set) var isHtmlDisabled: Bool?
    public private (set) var isUniversalSpam: Bool?
    public private (set) var notificationEmail: String?
    public private (set) var planType: String?
    public private (set) var blockExternalImage: Bool?
    
    // MARK: Constrcutor
    public init() {}
    
    public init(dictionary: [String: Any]) {
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
        self.isAttachmentsEncrypted = dictionary["is_attachments_encrypted"] as? Bool
        self.isSubjectEncrypted = dictionary["is_subject_encrypted"] as? Bool
        self.isContactsEncrypted = dictionary["is_contacts_encrypted"] as? Bool
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
        
        self.antiPhishingPhrase = dictionary["anti_phishing_phrase"] as? String
        self.attachmentSizeError = dictionary["attachment_size_error"] as? String
        self.attachmentSizeLimit = dictionary["attachment_size_limit"] as? Int
        self.e2eeNonct = dictionary["e2ee_nonct"] as? Bool
        self.enable2fa = dictionary["enable_2fa"] as? Bool
        self.enableForwarding = dictionary["enable_forwarding"] as? Bool
        self.forwardingAddress = dictionary["forwarding_address"] as? String
        self.isAntiPhishingEnabled = dictionary["is_anti_phishing_enabled"] as? Bool
        self.isHtmlDisabled = dictionary["is_html_disabled"] as? Bool
        let universalSpam = dictionary["universal_spam_filter"] as? Bool
        self.isUniversalSpam  = universalSpam
        self.notificationEmail = dictionary["notification_email"] as? String
        self.planType = dictionary["plan_type"] as? String
        self.blockExternalImage = dictionary["is_disable_loading_images"] as? Bool
    }
    
    public mutating func update(plan: String) {
        self.planType = plan
    }
    
    mutating func update(contactsEncrypted: Bool) {
        self.isContactsEncrypted = contactsEncrypted
    }
    
    mutating func update(subjectEncrypted: Bool) {
        self.isSubjectEncrypted = subjectEncrypted
    }
    
    mutating func update(attachmentEncrypted: Bool) {
        self.isAttachmentsEncrypted = attachmentEncrypted
    }
    
    mutating func update(saveContacts: Bool) {
        self.saveContacts = saveContacts
    }
    
    mutating func update(recoveryEmail: String?) {
        self.recoveryEmail = recoveryEmail
    }
    
   public  mutating func update(blockExternalImage: Bool) {
        self.blockExternalImage = blockExternalImage
    }
    
    public mutating func update(htmlEditor: Bool) {
        self.isHtmlDisabled = htmlEditor
    }
    
    public mutating func update(universalSpam: Bool) {
        self.isUniversalSpam = universalSpam
    }
}

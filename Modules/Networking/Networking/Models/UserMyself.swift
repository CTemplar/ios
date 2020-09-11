import Foundation
import Utility

public struct UserMyself {
    // MARK: Properties
    public private (set) var totalCount: Int?
    public private (set) var next: String?
    public private (set) var pageConut: Int?
    public private (set) var previous: String?
    public private (set) var mailboxesList: [Mailbox]?
    public private (set) var foldersList: [Folder]?
    public private (set) var contactsList: [Contact]?
    public private (set) var contactsWhiteList: [Contact]?
    public private (set) var contactsBlackList: [Contact]?
    public private (set) var username: String?
    public private (set) var isTrial: Bool?
    public private (set) var isPrime: Bool?
    public var settings: Settings = Settings()
        
    // MARK: - Constrcutor
    public init() {}
    
    public init(dictionary: [String: Any]) {
        self.totalCount = dictionary["total_count"] as? Int
        self.next = dictionary["next"] as? String
        self.pageConut = dictionary["page_count"] as? Int
        self.previous = dictionary["previous"] as? String
        if let resultsArray = dictionary["results"] as? Array<Any> {
            self.parsResults(array: resultsArray)
        }
    }
    
    // MARK: - Response Parser
    public mutating func parsResults(array: Array<Any>) {
        var localMailboxesList: [Mailbox]? = []
        var localFoldersList: [Folder]? = []
        var localContactsList: [Contact]? = []
        var localWhiteContactsList: [Contact]? = []
        var localBlackContactsList: [Contact]? = []
        
        for item in array {
            let dictionary = item as! Dictionary<String, Any>
            DPrint("dict keys:", dictionary.keys)
            for (key, value) in dictionary {
                if key == "mailboxes" {
                    let array = value as! Array<Any>
                    for item in array {
                        let mailboxDict = item as! [String: Any]
                        let mailbox = Mailbox(dictionary: mailboxDict)
                        localMailboxesList?.append(mailbox)
                    }
                }
                
                if key == "custom_folders" {
                    let array = value as! Array<Any>
                    for item in array {
                        let folderDict = item as! [String: Any]
                        let folder = Folder(dictionary: folderDict)
                        localFoldersList?.append(folder)
                    }
                }
                
                if key == "username" {
                    self.username = value as? String
                }
                
                if key == "contacts" {
                   let array = value as! Array<Any>
                    for item in array {
                        let contactDict = item as! [String: Any]
                        let contact = Contact(dictionary: contactDict)
                        localContactsList?.append(contact)
                    }
                }
                
                if key == "blacklist" {
                    let array = value as! Array<Any>
                    for item in array {
                        let contactDict = item as! [String: Any]
                        let contact = Contact(dictionary: contactDict)
                        localBlackContactsList?.append(contact)
                    }
                }
                
                if key == "whitelist" {
                    let array = value as! Array<Any>
                    for item in array {
                        let contactDict = item as! [String: Any]
                        let contact = Contact(dictionary: contactDict)
                        localWhiteContactsList?.append(contact)
                    }
                }
                
                if key == "is_trial" {
                    self.isTrial = value as? Bool
                }
                
                if key == "is_prime" {
                    self.isPrime = value as? Bool
                }
                
                if key == "settings" {
                    let settingsDict = value as! [String: Any]
                    self.settings = Settings(dictionary: settingsDict)
                }
            }
        }
        mailboxesList = localMailboxesList
        foldersList = localFoldersList
        contactsList = localContactsList
        contactsWhiteList = localWhiteContactsList
        contactsBlackList = localBlackContactsList
    }
    
    public mutating func update(contactsList: [Contact]?) {
        self.contactsList = contactsList
    }
}

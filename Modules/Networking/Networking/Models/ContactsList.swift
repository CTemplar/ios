import Foundation
import Utility

public struct ContactsList {
    // MARK: Properties
    public var totalCount: Int?
    public var next: String?
    public var pageConut: Int?
    public var previous: String?
    public var contactsList : Array<Contact>?
    private var pgpService: PGPService?

    // MARK: - Constructor
    public init(with pgpService: PGPService?) {
        self.pgpService = pgpService
    }
    
    public init(dictionary: [String: Any], pgpService: PGPService?) {
        self.pgpService = pgpService
        self.totalCount = dictionary["total_count"] as? Int
        self.next = dictionary["next"] as? String
        self.pageConut = dictionary["page_count"] as? Int
        self.previous = dictionary["previous"] as? String
        if let resultsArray = dictionary["results"] as? Array<Any> {
            self.contactsList = self.parsResultsFromList(array: resultsArray)
        }
    }
    
    public func parsResultsFromList(array: Array<Any>) -> Array<Contact>{
        var objectsArray = [Contact]()
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {
                let contactsResult = Contact(dictionary: objectDictionary)
                
                if contactsResult.isEncrypted ?? false {
                    if let unwrappedData = contactsResult.encryptedData {
                        let encryptedDictionary = self.decryptContactData(encryptedData: unwrappedData)
                        let encryptedContact = Contact(encryptedDictionary: encryptedDictionary, contactId: contactsResult.contactID ?? 0, encryptedData: unwrappedData)
                        objectsArray.append(encryptedContact)
                    }
                } else {
                    objectsArray.append(contactsResult)
                }
            }
        }
        
        return objectsArray
    }
    
    public func decryptContactData(encryptedData: String) -> [String: Any] {
        guard let decryptedContent = pgpService?.decryptMessage(encryptedContet: encryptedData) else {
            return [:]
        }
        let dictionary = convertStringToDictionary(text: decryptedContent)
        return dictionary
    }
    
    public func convertStringToDictionary(text: String) -> [String:Any] {
        var dicitionary = [String: Any]()
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    dicitionary = json
                }
                return dicitionary
                
            } catch {
                DPrint("convertStringToDictionary: Something went wrong string ->", text)
                return dicitionary
            }
        }
        return dicitionary
    }
}

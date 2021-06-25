import Foundation

public struct Mailboxes {
    // MARK: Propeties
    public var previous: String? = nil
    public var totalCount: Int? = nil
    public var next: String? = nil
    public var pageConut: Int? = nil
    public var mailboxesResultsList : Array<Mailbox>? = nil
    
    // MARK: - Constructor
    public init() {
        
    }
    
    public init(dictionary: [String: Any], _ isFromExtraKeys:Bool = false) {
        self.previous = dictionary["previous"] as? String
        self.next = dictionary["next"] as? String
        self.totalCount = dictionary["total_count"] as? Int
        self.pageConut = dictionary["page_count"] as? Int
        if let resultsArray = dictionary["results"] as? Array<Any> {
            self.mailboxesResultsList = self.parsResultsFromList(array: resultsArray, isFromExtraKeys)
        }
    }
    
    // MARK: - Parsing
    public func parsResultsFromList(array: Array<Any>, _ isFromExtraKeys:Bool = false) -> [Mailbox] {
        var objectsArray: [Mailbox] = []
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {
                let messageResult = Mailbox(dictionary: objectDictionary, isFromExtraKeys)
                objectsArray.append(messageResult)
            }
        }
        return objectsArray
    }
}

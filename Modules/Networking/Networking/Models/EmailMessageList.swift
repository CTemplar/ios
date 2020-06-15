import Foundation

public struct EmailMessagesList {
    public var next: String?
    public var pageConut: Int?
    public var previous: String?
    public var messagesList : Array<EmailMessage>?
    public var totalCount: Int?
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        self.next = dictionary["next"] as? String
        self.pageConut = dictionary["page_count"] as? Int
        self.previous = dictionary["previous"] as? String
        
        if let resultsArray = dictionary["results"] as? Array<Any> {
            self.messagesList = self.parsResultsFromList(array: resultsArray)
        }
        
        self.totalCount = dictionary["total_count"] as? Int
    }
    
    func parsResultsFromList(array: Array<Any>) -> Array<EmailMessage>{
        
        var objectsArray: Array<EmailMessage> = []
        
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {//[String : Any] {
                let messageResult = EmailMessage(dictionary: objectDictionary)
                objectsArray.append(messageResult)
            }
        }
        
        print("new messages count:", objectsArray.count)
        
        return objectsArray
    }
}

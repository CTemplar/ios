import Foundation

public struct FolderList {
    // MARK: Properties
    public var next: String?
    public var pageConut: Int?
    public var previous: String?
    public var foldersList : Array<Folder>?
    public var totalCount: Int?
    
    // MARK: - Constructor
    init() {
    }
    
    init(dictionary: [String: Any]) {
        self.next = dictionary["next"] as? String
        self.pageConut = dictionary["page_count"] as? Int
        self.previous = dictionary["previous"] as? String
        if let resultsArray = dictionary["results"] as? Array<Any> {
            self.foldersList = self.parsResultsFromList(array: resultsArray)
        }
        self.totalCount = dictionary["total_count"] as? Int
    }
    
    // MARK: - Parsing
    func parsResultsFromList(array: [Any]) -> [Folder] {
        var objectsArray: [Folder] = []
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {
                let folderResult = Folder(dictionary: objectDictionary)
                objectsArray.append(folderResult)
            }
        }
        return objectsArray
    }
}

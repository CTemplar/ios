import Foundation

public struct Folder {
    // MARK: Properties
    public private (set) var color: String?
    public private (set) var folderName: String?
    public private (set) var folderID: Int?
    
    // MARK: - Construtor
    public init() {}
    
    public init(dictionary: [String: Any]) {
        self.color = dictionary["color"] as? String
        self.folderName = dictionary["name"] as? String
        self.folderID = dictionary["id"] as? Int
    }
    
    static public func folderFromName(name: String)-> Folder {
        var folder = Folder()
        folder.color = ""
        folder.folderName = name
        folder.folderID = 0
        return folder
    }
}

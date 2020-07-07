import Foundation

public struct UnreadMessagesCounter {
    // MARK: Properties
    public var folderName: String?
    public var unreadMessagesCount: Int?
    
    // MARK: Constructor
    public init() {
    }
    
    public init(key: String, value: Any) {
        self.folderName = key
        self.unreadMessagesCount = value as? Int
    }
}

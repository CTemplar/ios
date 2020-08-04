import Utility

public struct Subject: Modelable {
    // MARK: Properties
    let title: String
    let isProtected: Bool
    let isSecured: Bool
    var isStarred: Bool
    
    // MARK: - Constructor
    public init(title: String, isProtected: Bool, isSecured: Bool, isStarred: Bool) {
        self.title = title
        self.isProtected = isProtected
        self.isSecured = isSecured
        self.isStarred = isStarred
    }
    
    // MARK: - Update
    public mutating func update(isStarred: Bool) {
        self.isStarred = isStarred
    }
}

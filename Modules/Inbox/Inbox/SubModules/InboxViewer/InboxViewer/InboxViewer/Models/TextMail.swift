import Utility

public struct TextMail: Modelable {
    // MARK: Properties
    let messageId: Int?
    let content: String
    let shouldBlockExternalImages: Bool
    var state: InboxHeaderState
    
    // MARK: - Constructor
    public init(messageId: Int?, content: String, state: InboxHeaderState, shouldBlockExternalImages: Bool) {
        self.messageId = messageId
        self.content = content
        self.state = state
        self.shouldBlockExternalImages = shouldBlockExternalImages
    }
    
    // MARK: - Update
    public mutating func update(state: InboxHeaderState) {
        self.state = state
    }
}

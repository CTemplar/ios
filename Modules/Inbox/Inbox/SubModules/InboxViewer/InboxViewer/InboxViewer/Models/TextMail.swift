import Utility

public struct TextMail: Modelable {
    // MARK: Properties
    let messageId: Int?
    let content: String
    var state: InboxHeaderState
    
    // MARK: - Constructor
    public init(messageId: Int?, content: String, state: InboxHeaderState) {
        self.messageId = messageId
        self.content = content
        self.state = state
    }
    
    // MARK: - Update
    public mutating func update(state: InboxHeaderState) {
        self.state = state
    }
}

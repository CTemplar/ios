import Utility
import CoreGraphics

public struct TextMail: Modelable {
    // MARK: Properties
    let messageId: Int?
    let content: String
    let shouldBlockExternalImages: Bool
    var contentHeight: [Int: CGFloat]
    var state: InboxHeaderState
    
    // MARK: - Constructor
    public init(messageId: Int?, content: String, state: InboxHeaderState, contentHeight: [Int: CGFloat], shouldBlockExternalImages: Bool) {
        self.messageId = messageId
        self.content = content
        self.state = state
        self.shouldBlockExternalImages = shouldBlockExternalImages
        self.contentHeight = contentHeight
    }
    
    // MARK: - Update
    public mutating func update(state: InboxHeaderState) {
        self.state = state
    }
    
    public mutating func update(contentHeight: [Int: CGFloat]) {
        self.contentHeight = contentHeight
    }
}

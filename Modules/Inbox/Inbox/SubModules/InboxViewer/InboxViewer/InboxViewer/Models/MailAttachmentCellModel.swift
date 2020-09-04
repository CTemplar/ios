import Foundation
import Utility
import Combine
import CoreGraphics

public final class MailAttachmentCellModel: Modelable {
    // MARK: Properties
    @Published public private (set) var attachments: [MailAttachment] = []
    
    private (set) var spacing: CGFloat = 5.0
    
    public var rowHeight: CGFloat? {
        return attachments.isEmpty ? nil : 100.0
    }
    
    // MARK: - Constructor
    public init(attachments: [MailAttachment], spacing: CGFloat = 5.0) {
        self.attachments = attachments
        self.spacing = spacing
    }
    
    // MARK: - Update
    public func update(attachment: MailAttachment) {
        if let index = attachments
            .firstIndex(where: { $0.contentURL == attachment.contentURL }) {
            attachments.remove(at: index)
        } else {
            attachments.append(attachment)
        }
    }
}

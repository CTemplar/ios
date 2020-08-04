import Foundation
import Utility

public struct MailAttachmentCellModel: Modelable {
    // MARK: Properties
    let attachmentes: [MailAttachment]
    
    // MARK: - Constructor
    public init(attachmentes: [MailAttachment]) {
        self.attachmentes = attachmentes
    }
}

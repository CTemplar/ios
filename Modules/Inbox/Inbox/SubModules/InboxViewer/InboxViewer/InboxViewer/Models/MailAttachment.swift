import Foundation
import Utility

public struct MailAttachment: Modelable {
    // MARK: Properties
    let attachmentTitle: String
    let contentURL: String
    let attachmentType: GeneralConstant.DocumentsExtension
    let encrypted: Bool
    
    // MARK: - Constructor
    public init(attachmentTitle: String,
                attachmentType: GeneralConstant.DocumentsExtension,
                contentURL: String,
                encrypted: Bool) {
        self.attachmentTitle = attachmentTitle
        self.attachmentType = attachmentType
        self.contentURL = contentURL
        self.encrypted = encrypted
    }
}

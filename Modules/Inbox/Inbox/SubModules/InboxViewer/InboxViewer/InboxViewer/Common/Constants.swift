import Foundation
import Networking

public struct InboxViewerConstant {
    public static let attachmentFileName = "tempFile"
}

enum InboxViewerSection {
    case subject(Subject)
    case mailBody(TextMail, Bool)
    case attachment(MailAttachmentCellModel)
}

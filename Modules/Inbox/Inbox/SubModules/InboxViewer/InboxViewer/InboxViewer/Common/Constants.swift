import Foundation
import Networking

struct InboxViewerConstant {
    static let attachmentFileName = "tempFile"
}

enum InboxViewerSection {
    case subject(Subject)
    case mailBody(TextMail, Bool)
    case attachment(MailAttachmentCellModel)
}

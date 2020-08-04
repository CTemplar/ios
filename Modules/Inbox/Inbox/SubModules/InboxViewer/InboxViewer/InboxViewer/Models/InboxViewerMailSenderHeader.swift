import Utility
import UIKit

public enum SenderType {
    case from(String)
    case to(String)
    case cc(String)
    case bcc(String)
}

public enum InboxHeaderState {
    case expanded
    case collapsed
}

public struct EmailProperty {
    let timerText: NSAttributedString
    let deleteText: NSAttributedString
    let timerBackgroundColor: UIColor
    let deleteBackgroundColor: UIColor
}

public struct InboxViewerMailSenderHeader: Modelable {
    // MARK: Properties
    let senderName: String
    let receiverEmailId: String
    let mailSentDate: String
    let detailMailIdsWithAttribute: [SenderType] // Like CC: nirit@dev.ctemplar.com
    let emailProperty: EmailProperty?
    let isTappable: Bool
    let state: InboxHeaderState
    
    // MARK: - Constructor
    public init(senderName: String,
                receiverEmailId: String,
                mailSentDate: String,
                detailMailIdsWithAttribute: [SenderType],
                emailProperty: EmailProperty?,
                isTappable: Bool = false,
                state: InboxHeaderState = .collapsed) {
        self.senderName = senderName
        self.receiverEmailId = receiverEmailId
        self.mailSentDate = mailSentDate
        self.detailMailIdsWithAttribute = detailMailIdsWithAttribute
        self.emailProperty = emailProperty
        self.isTappable = isTappable
        self.state = state
    }
}

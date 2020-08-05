import Foundation
import FBSnapshotTestCase
@testable import InboxViewer

class AttachmentCellTests: FBSnapshotBase {
    private var models: [MailAttachment] {
        return [MailAttachment(attachmentTitle: "message_8d3dca6b5b2849d3a4aba8752b773c33",
                               attachmentType: .doc,
                               contentURL: "",
                               encrypted: false),
                MailAttachment(attachmentTitle: "message_8d3dca6b5b2849d3a4aba8752b773c33",
                               attachmentType: .pdf,
                               contentURL: "",
                               encrypted: false),
                MailAttachment(attachmentTitle: "message_8d3dca6b5b2849d3a4aba8752b773c33",
                               attachmentType: .jpg,
                               contentURL: "",
                               encrypted: false),
                MailAttachment(attachmentTitle: "message_8d3dca6b5b2849d3a4aba8752b773c33",
                               attachmentType: .png,
                               contentURL: "",
                               encrypted: false)]
    }
    
    override func setUp() {
        super.setUp()
        // self.recordMode = true
    }
    
    func testAttachmentCell() {
        let cell = AttachmentCell(style: .default, reuseIdentifier: InboxViewerSubjectCell.className)
        cell.configure(with: MailAttachmentCellModel(attachmentes: models))
        cell.frame.size.height = 80.0
        FBSnapshotVerifyView(cell)
    }
}

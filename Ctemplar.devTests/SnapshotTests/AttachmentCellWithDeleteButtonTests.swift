import Foundation
import FBSnapshotTestCase
@testable import InboxViewer

class AttachmentCellWithDeleteButtonTests: FBSnapshotBase {
    private var models: [MailAttachment] {
        return [MailAttachment(attachmentTitle: "message_8d3dca6b5b2849d3a4aba8752b773c33",
                               attachmentType: .doc,
                               contentURL: "",
                               encrypted: false,
                               shoulDisplayRemove: true),
                MailAttachment(attachmentTitle: "message_8d3dca6b5b2849d3a4aba8752b773c33",
                               attachmentType: .pdf,
                               contentURL: "",
                               encrypted: false,
                               shoulDisplayRemove: true),
                MailAttachment(attachmentTitle: "message_8d3dca6b5b2849d3a4aba8752b773c33",
                               attachmentType: .jpg,
                               contentURL: "",
                               encrypted: false,
                               shoulDisplayRemove: true),
                MailAttachment(attachmentTitle: "message_8d3dca6b5b2849d3a4aba8752b773c33",
                               attachmentType: .png,
                               contentURL: "",
                               encrypted: false,
                               shoulDisplayRemove: true)]
    }
    
    override func setUp() {
        super.setUp()
        // self.recordMode = true
    }
    
    func testAttachmentCellWithDeleteButton() {
        let cell = AttachmentCell(style: .default, reuseIdentifier: InboxViewerSubjectCell.className)
        cell.configure(with: MailAttachmentCellModel(attachments: models))
        cell.frame.size.height = 80.0
        FBSnapshotVerifyView(cell)
    }
}

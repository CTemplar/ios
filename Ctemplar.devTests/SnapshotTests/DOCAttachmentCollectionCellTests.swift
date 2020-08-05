import Foundation
import UIKit
import FBSnapshotTestCase
@testable import InboxViewer

class DOCAttachmentCollectionCellTests: FBSnapshotBase {
    private var attachment: MailAttachment {
        return MailAttachment(attachmentTitle: "message_8d3dca6b5b2849d3a4aba8752b773c33",
                              attachmentType: .doc,
                              contentURL: "", encrypted: false)
    }
    
    override func setUp() {
        super.setUp()
        // self.recordMode = true
    }
    
    func testDOCAttachmentCollectionCell() {
        let cell = AttachmentCollectionCell(frame: CGRect(x: 0.0,
                                                          y: 0.0,
                                                          width: 100.0,
                                                          height: 70.0)
        )
        
        cell.configure(with: attachment)
        FBSnapshotVerifyView(cell)
    }
}

import Foundation
import FBSnapshotTestCase
@testable import InboxViewer

class InboxViewerTextMailBodyCellTests: FBSnapshotBase {
    private var content: TextMail {
        return TextMail(messageId: 12345,
                        content: """
                         Welcome to the future of email!

                                You now have an inbox that is protected by strong encryption. Even we do not have the ability to read your emails. CTemplar can send and receive emails from other email providers such as Gmail. It is even possible to end-to-end encrypt the messages you send to external recipients. If your friends also use CTemplar, all your communications with them will be automatically end-to-end encrypted.

                                CTemplar is an open-source community-driven project and basic accounts are always free. However, the costs to run CTemplar are quite high, and we depend on support from the community to keep the service running. If you would like to support the project, you can upgrade to a paid account. Your support is essential to ensuring that CTemplar is financially stable and can continue to offer the service to the public.
                        """,
                        state: .expanded)
    }
    
    override func setUp() {
        super.setUp()
        // self.recordMode = true
    }
    
    func testContentCell() {
        let contentCell = InboxViewerTextMailBodyCell(style: .default, reuseIdentifier: InboxViewerTextMailBodyCell.className)
        contentCell.configure(with: content)
        contentCell.frame.size.height = 200.0
        FBSnapshotVerifyView(contentCell)
    }
}

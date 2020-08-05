import Foundation
import FBSnapshotTestCase
import CoreGraphics
import UIKit
import Utility
@testable import InboxViewer

class InboxViewerMailSenderHeaderViewCollapsedTests: FBSnapshotBase {
    private var headerModel: InboxViewerMailSenderHeader {
        return InboxViewerMailSenderHeader(senderName: "Nivrit Gupta",
                                           receiverEmailId: "nirit@dev.ctemplar.com",
                                           mailSentDate: "Jul 17, 2020, 20:14:28 PM",
                                           detailMailIdsWithAttribute: [.from("gupta.nivrit@gmail.com"),
                                           .to("nivritgupta11@dev.ctemplar.com"),
                                           .cc("nirit@dev.ctemplar.com")],
                                           emailProperty: .init(timerText: NSAttributedString(string: "18:34"),
                                                                deleteText: NSAttributedString(string: "Delay Delivery in 0d"),
                                                                timerBackgroundColor: k_redColor, deleteBackgroundColor: k_orangeColor))
    }
    
    override func setUp() {
        super.setUp()
        // self.recordMode = true
    }
    
    func testInboxViewerMailSenderHeaderViewCollapsedState() {
        let headerView = InboxViewerMailSenderHeaderView(frame: CGRect(x: 0.0,
                                                                       y: 0.0,
                                                                       width: UIScreen.main.bounds.size.width,
                                                                       height: 80.0)
        )
        headerView.configure(with: headerModel)
        FBSnapshotVerifyView(headerView)
    }
}

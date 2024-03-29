import Foundation
import FBSnapshotTestCase
@testable import InboxViewer

class InboxViewerTitleCellTests: FBSnapshotBase {
    private var subject: Subject {
        return Subject(title: "Welcome to CTemplar!", isProtected: true, isSecured: true, isStarred: true)
    }
    
    override func setUp() {
        super.setUp()
        // self.recordMode = true
    }
    
    func testTitleCell() {
        let titleCell = InboxViewerSubjectCell(style: .default, reuseIdentifier: InboxViewerSubjectCell.className)
        titleCell.configure(with: subject)
        titleCell.frame.size.height = 50.0
        FBSnapshotVerifyView(titleCell)
    }
}

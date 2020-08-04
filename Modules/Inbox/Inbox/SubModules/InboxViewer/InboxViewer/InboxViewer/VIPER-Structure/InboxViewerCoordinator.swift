import Foundation
import UIKit
import Utility
import Networking
import Inbox

public class InboxViewerCoordinator {
    private var conigurator: InboxViewerConfigurator?
    
    public init() {}
    
    public func showInboxViewer(withUser user: UserMyself?,
                                message: EmailMessage?,
                                onReply: InboxViewerAction?,
                                onForward: InboxViewerAction?,
                                onReplyAll: InboxViewerAction?,
                                onMoveTo: MoveToAction?,
                                viewInboxDelegate: ViewInboxEmailDelegate?,
                                presenter: UIViewController?) {
        let inboxViewer: InboxViewerController = UIStoryboard(storyboard: .inboxViewer,
                                                              bundle: Bundle(for: InboxViewerController.self)
        ).instantiateViewController()
        
        conigurator = InboxViewerConfigurator(with:
            [
                .inboxViewer(inboxViewer),
                .message(message),
                .onTapForward(onForward),
                .onTapReply(onReply),
                .onTapReplyAll(onReplyAll),
                .user(user),
                .onTapMoveTo(onMoveTo),
                .viewInboxDelegate(viewInboxDelegate)
            ]
        )
        
        conigurator?.setup()
        
        presenter?.navigationController?.pushViewController(inboxViewer, animated: true)
    }
}

import Foundation
import SideMenu
import UIKit
import Networking
import Utility
import Inbox

final class InboxViewerRouter {
    // MARK: Properties
    private weak var inboxViewerController: InboxViewerController?
    private var onTapReply: InboxViewerAction?
    private var onTapReplyAll: InboxViewerAction?
    private var onTapForward: InboxViewerAction?
    private var onTapMoveTo: MoveToAction?

    // MARK: - Constructor
    init(inboxViewController: InboxViewerController?,
         onTapReply: InboxViewerAction?,
         onTapReplyAll: InboxViewerAction?,
         onTapForward: InboxViewerAction?,
         onTapMoveTo: MoveToAction?) {
        self.inboxViewerController = inboxViewController
        self.onTapReply = onTapReply
        self.onTapReplyAll = onTapReplyAll
        self.onTapForward = onTapForward
        self.onTapMoveTo = onTapMoveTo
    }
    
    // MARK: - Navigations
    func onTapReply(withMode answerMode: AnswerMessageMode, message: EmailMessage?) {
        onTapReply?(answerMode, message, inboxViewerController)
    }
    
    func onTapReplyAll(withMode answerMode: AnswerMessageMode, message: EmailMessage?) {
        onTapReplyAll?(answerMode, message, inboxViewerController)
    }
    
    func onTapForward(withMode answerMode: AnswerMessageMode, message: EmailMessage?) {
        onTapForward?(answerMode, message, inboxViewerController)
    }
    
    func onTapMoveTo(withDelegate delegate: MoveToViewControllerDelegate?, messageId: Int, user: UserMyself) {
        onTapMoveTo?(delegate, messageId, user, inboxViewerController)
    }
    
    func backToParent() {
        inboxViewerController?.navigationController?.popViewController(animated: true)
    }
}

import Foundation
import UIKit
import Networking
import Utility
import Inbox

public typealias InboxViewerAction = ((AnswerMessageMode, EmailMessage?, UIViewController?) -> Void)
public typealias MoveToAction = ((MoveToViewControllerDelegate?, Int, UserMyself, UIViewController?) -> Void)

class InboxViewerConfigurator: Configurable {
    // MARK: Properties
    typealias AdditionalConfig = InboxViewerConfig

    enum InboxViewerConfig: Configuration {
        case inboxViewer(InboxViewerController?)
        case user(UserMyself?)
        case message(EmailMessage?)
        case onTapReply(InboxViewerAction?)
        case onTapReplyAll(InboxViewerAction?)
        case onTapForward(InboxViewerAction?)
        case onTapMoveTo(MoveToAction?)
        case viewInboxDelegate(ViewInboxEmailDelegate?)
    }
    
    private var user: UserMyself?
    private var message: EmailMessage?
    private var inboxViewerVC: InboxViewerController?
    private var onTapReply: InboxViewerAction?
    private var onTapReplyAll: InboxViewerAction?
    private var onTapForward: InboxViewerAction?
    private var onTapMoveTo: MoveToAction?
    private weak var viewInboxDelegate: ViewInboxEmailDelegate?

    // MARK: - Constructor
    required init(with configs: [InboxViewerConfig]) {
        configs.forEach { (config) in
            switch config {
            case .user(let user):
                self.user = user
            case .inboxViewer(let vc):
                self.inboxViewerVC = vc
            case .message(let msg):
                self.message = msg
            case .onTapMoveTo(let closure):
                self.onTapMoveTo = closure
            case .viewInboxDelegate(let delegate):
                self.viewInboxDelegate = delegate
            case .onTapForward(let closure):
                self.onTapForward = closure
            case .onTapReply(let closure):
                self.onTapReply = closure
            case .onTapReplyAll(let closure):
                self.onTapReplyAll = closure
            }
        }
    }
    
    func setup() {
        guard let inboxViewerController = inboxViewerVC else {
            return
        }
        
        let router = InboxViewerRouter(inboxViewController: inboxViewerController,
                                       onTapReply: onTapReply,
                                       onTapReplyAll: onTapReplyAll,
                                       onTapForward: onTapForward,
                                       onTapMoveTo: onTapMoveTo)
        let interactor = InboxViewerInteractor()
        
        let presenter = InboxViewerPresenter(viewController: inboxViewerController, interactor: interactor)
        
        interactor.setup(inboxViewerController: inboxViewerVC)
        
        if let msg = message {
            inboxViewerController.setup(message: msg)
        }
        
        if let user = self.user {
            inboxViewerController.setup(user: user)
        }
        
        inboxViewerController.setup(router: router)
        
        inboxViewerController.setup(presenter: presenter)
        
        inboxViewerController.setup(delegate: viewInboxDelegate)
    }
}

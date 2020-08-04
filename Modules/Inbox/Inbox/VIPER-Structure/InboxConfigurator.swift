import Foundation
import UIKit
import Networking
import Utility

class InboxConfigurator {
    func configure(inboxViewController: InboxViewController,
                   onTapCompose: ((AnswerMessageMode, UserMyself, UIViewController?) -> Void)?,
                   onTapComposeWithDraft: ((AnswerMessageMode, EmailMessage, UserMyself, UIViewController?) -> Void)?,
                   onTapSearch: ((UserMyself, UIViewController?) -> Void)?,
                   onTapViewInbox: ((EmailMessage?, UserMyself?, ViewInboxEmailDelegate?, UIViewController?) -> Void)?,
                   onTapMoveTo: ((MoveToViewControllerDelegate?, [Int], UserMyself, UIViewController?) -> Void)?
    ) {
        
        let router = InboxRouter(inboxViewController: inboxViewController,
                                 onTapCompose: onTapCompose,
                                 onTapComposeWithDraft: onTapComposeWithDraft,
                                 onTapSearch: onTapSearch,
                                 onTapViewInbox: onTapViewInbox,
                                 onTapMoveTo: onTapMoveTo
        )
        
        let interactor = InboxInteractor(viewController: inboxViewController)
        
        let presenter = InboxPresenter(interactor: interactor, viewController: inboxViewController)
        
        interactor.update(presenter: presenter)
                
        inboxViewController.setup(presenter: presenter)
        inboxViewController.setup(router: router)
    }
}

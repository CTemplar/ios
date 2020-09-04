import Foundation
import UIKit
import Utility
import Networking

public final class ComposeCoordinator {
    // MARK: Properties
    private var composeController: ComposeController?
    
    // MARK: - Constructor
    public init() {}
    
    public func showCompose(from viewController: UIViewController?,
                            withUser user: UserMyself,
                            existingEmail: EmailMessage?,
                            answerMode: AnswerMessageMode,
                            includeAttachments: Bool) {
        
        composeController = UIStoryboard(storyboard: .compose,
                                         bundle: Bundle(for: ComposeController.self)
        ).instantiateViewController()
        
        if let email = existingEmail {
            let viewModel = ComposeViewModel(answerMode: answerMode,
                                             user: user,
                                             message: email,
                                             includeAttachments: includeAttachments)
            composeController?.configure(with: viewModel)
        } else {
            let viewModel = ComposeViewModel(answerMode: answerMode, user: user)
            composeController?.configure(with: viewModel)
        }

        viewController?.navigationController?.pushViewController(composeController!, animated: true)
    }
}

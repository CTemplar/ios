import Foundation
import Networking

final class GlobalSearchRouter {
    // MARK: Properties
    private weak var searchController: GlobalSearchViewController?
    private var onTapMessage: ((EmailMessage, UserMyself) -> Void)
    
    // MARK: - Constructor
    init(searchController: GlobalSearchViewController?, onTapMessage: @escaping ((EmailMessage, UserMyself) -> Void)) {
        self.searchController = searchController
        self.onTapMessage = onTapMessage
    }
    
    // MARK: - Show Detail Inbox
    func showInboxDetail(forMessage message: EmailMessage, user: UserMyself) {
        onTapMessage(message, user)
    }
}

import Foundation
import Networking
import Inbox

final class GlobalSearchRouter {
    // MARK: Properties
    private weak var searchController: GlobalSearchViewController?
    private var onTapMessage: ((EmailMessage, UserMyself, ViewInboxEmailDelegate?) -> Void)
    
    // MARK: - Constructor
    init(searchController: GlobalSearchViewController?, onTapMessage: @escaping ((EmailMessage, UserMyself, ViewInboxEmailDelegate?) -> Void)) {
        self.searchController = searchController
        self.onTapMessage = onTapMessage
    }
    
    // MARK: - Show Detail Inbox
    func showInboxDetail(forMessage message: EmailMessage, user: UserMyself) {
        onTapMessage(message, user, searchController)
    }
}

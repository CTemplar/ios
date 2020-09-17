import Utility
import Networking
import UIKit

extension InboxDatasource {
    func setInboxData(by messages: [EmailMessage],
                      withTotalCount totalCount: Int,
                      pageOffset offset: Int) {
     
        func openDetails(withMessageId messageId: Int) {
            if let message = messages.first(where: { $0.messsageID == messageId }) {
                showDetails(of: message)
            }
        }
        
        if offset == 0 {
           reset()
        }
                
        // Update/Insert new message
        update(messages: messages)
        
        // Sorting by creation date
        sortMessages()
        
        // Reload the Inbox
        reload()
        
        // Disable the selection mode
        disableSelectionIfSelected()
        
        // Refresh Inbox UI
        invokeRefreshUI()
        
        if filterEnabled {
            applyFilters()
        }
    
        // Open Inbox Details from Push notification
        if SharedInboxState.shared.incomingMessageId != -1 {
            update(messageId: SharedInboxState.shared.incomingMessageId)
        }
        
        if messageId != -1 {
            openDetails(withMessageId: messageId)
        }
    }
}

import Foundation
import Networking

public protocol ViewInboxEmailDelegate {
    func didUpdateReadStatus(for message: EmailMessage, status: Bool)
}

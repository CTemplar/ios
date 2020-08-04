import Foundation
import Networking

public protocol ViewInboxEmailDelegate: class {
    func didUpdateReadStatus(for message: EmailMessage, status: Bool)
}

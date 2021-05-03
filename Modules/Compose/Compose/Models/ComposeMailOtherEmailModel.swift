import Utility
import Networking
import Combine
import UIKit

public final class ComposeMailOtherEmailModel: Modelable, ObservableObject  {
    // MARK: Properties
    @Published private (set) var mailIds: [String] = []
    
    @Published private (set) var collapsed = true

    var subject = PassthroughSubject<(String, Bool), Never>()
    
    var height: CGFloat = 50.0
    
    private (set) var mode: SenderPrefixMode
    
    private (set) var indexPath: IndexPath
    
    private (set) var contacts: [Contact]
    
    private (set) var isContactsEncrypted: Bool
        
    private var bindables = Set<AnyCancellable>()
    
    lazy var insets: UIEdgeInsets = {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }()
    
    lazy var fontSize: CGFloat = {
        return 16.0
    }()

    // MARK: - Constructor
    public init(mode: SenderPrefixMode,
                contacts: [Contact],
                mailIds: [String],
                isContactsEncrypted: Bool,
                indexPath: IndexPath) {
        self.mode = mode
        self.contacts = contacts
        self.mailIds = mailIds
        self.isContactsEncrypted = isContactsEncrypted
        self.indexPath = indexPath
        self.setupObserver()
    }
    
    public init(mode: SenderPrefixMode,
                mailIds: [String],
                isContactsEncrypted: Bool,
                indexPath: IndexPath) {
        self.mode = mode
        self.mailIds = mailIds
        self.contacts = []
        self.isContactsEncrypted = isContactsEncrypted
        self.indexPath = indexPath
        self.setupObserver()
    }
    
    public func updateContacts(contacts: [Contact]) {
        self.contacts = contacts
    }
    private func setupObserver() {
        subject
            .sink(receiveValue: { [weak self] in
                self?.update(mailId: $0.0, shouldAdd: $0.1)
        })
            .store(in: &bindables)
    }
    
    // MARK: - Update
    private func update(mailId: String, shouldAdd: Bool) {
        switch shouldAdd {
        case true:
            if !mailIds.contains(mailId) {
                mailIds.append(mailId)
            }
        case false:
            mailIds.removeAll(where: { $0 == mailId })
        }
    }

    func updateState(_ isCollapsed: Bool) {
        self.collapsed = isCollapsed
    }
}

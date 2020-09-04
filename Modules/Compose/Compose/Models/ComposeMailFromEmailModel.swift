import Utility
import Networking
import Combine
import UIKit

public final class ComposeMailFromEmailModel: Modelable, ObservableObject  {
    // MARK: Properties
    @Published private (set) var mailId = ""
    
    var subject = PassthroughSubject<String, Never>()
    
    private var bindables = Set<AnyCancellable>()

    lazy var fontSize: CGFloat = {
        return 16.0
    }()

    // MARK: - Constructor
    public init(mailId: String) {
        self.mailId = mailId
        self.setupObserver()
    }
    
    private func setupObserver() {
        subject
            .subscribe(on: RunLoop.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] in
            self?.update(mailId: $0)
        })
            .store(in: &bindables)
    }
    
    // MARK: - Update
    func update(mailId: String) {
        self.mailId = mailId
    }
}

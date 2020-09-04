import Utility
import Combine
import CoreGraphics

public final class ComposeMailSubjectModel: Modelable {
    // MARK: Properties
    @Published var content: String
    private (set) var subject = PassthroughSubject<String, Never>()
    private var bindables = Set<AnyCancellable>()
    var cellHeight: CGFloat = 120.0
    
    // MARK: - Constructor
    public init(content: String) {
        self.content = content
    }
}

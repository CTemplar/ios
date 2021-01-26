import Utility
import Combine
import CoreGraphics

public enum ContentType {
    case htmlText
    case normalText
}

public final class ComposeMailSubjectModel: Modelable {
    // MARK: Properties
    @Published var content: String
    private (set) var subject = PassthroughSubject<String, Never>()
    private (set) var contentTypeSubject = PassthroughSubject<ContentType, Never>()
    private (set) var contentType: ContentType = .htmlText
    private var bindables = Set<AnyCancellable>()
    var cellHeight: CGFloat = 120.0
    
    // MARK: - Constructor
    public init(content: String, contentType: ContentType) {
        self.content = content
        self.contentType = contentType
        self.contentTypeSubject.sink(receiveValue: { [weak self] in
            self?.contentType = $0
            }).store(in: &bindables)
        subject.sink { (str) in
            self.content = str
        }.store(in: &bindables)
    }
    
    deinit {
        bindables.forEach({
            $0.cancel()
        })
        bindables.removeAll()
    }
}

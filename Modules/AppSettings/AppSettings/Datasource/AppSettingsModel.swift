import Utility
import UIKit

public struct AppSettingsModel: Modelable {
    // MARK: Properties
    let title: String
    var subtitle: String?
    let showDetailIndicator: Bool
    let selectable: Bool
    var titleAlignment: NSTextAlignment = .left
    var titleColor: UIColor = .label
    var titleFont: UIFont = .withType(.Default(.Normal))
    
    // MARK: - Constructor
    public init(title: String,
                subtitle: String? = nil,
                showDetailIndicator: Bool = true,
                selectable: Bool = true,
                titleAlignment: NSTextAlignment = .left,
                titleColor: UIColor = .label,
                titleFont: UIFont = .withType(.Default(.Normal))) {
        self.title = title
        self.subtitle = subtitle
        self.showDetailIndicator = showDetailIndicator
        self.selectable = selectable
        self.titleAlignment = titleAlignment
        self.titleColor = titleColor
        self.titleFont = titleFont
    }
    
    // MARK: - Update
    public mutating func update(subtitle: String) {
        self.subtitle = subtitle
    }
}

extension AppSettingsModel: Equatable {
    public static func ==(lhs: AppSettingsModel, rhs: AppSettingsModel) -> Bool {
        return lhs.title == rhs.title
    }
}

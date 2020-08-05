import Utility
import UIKit

public struct AppSettingsModel: Modelable {
    // MARK: Properties
    let title: String
    var subtitle: String?
    let showDetailIndicator: Bool
    let selectable: Bool
    var titleAlignment: NSTextAlignment = .left
    var titleColor: UIColor = k_settingsCellTextColor
    var titleFont: UIFont = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)!
    
    // MARK: - Constructor
    public init(title: String,
                subtitle: String? = nil,
                showDetailIndicator: Bool = true,
                selectable: Bool = true,
                titleAlignment: NSTextAlignment = .left,
                titleColor: UIColor = k_settingsCellTextColor,
                titleFont: UIFont = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)!) {
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

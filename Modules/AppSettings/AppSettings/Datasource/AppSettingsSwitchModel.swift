import Utility
import UIKit
import Combine

public final class AppSettingsSwitchModel: Modelable {
    // MARK: Properties
    let title: String
    var value: Bool
    var rowType: SettingsRow
    var titleColor: UIColor = .label
    var titleFont: UIFont = .withType(.Default(.Normal))
    
    // MARK: - Constructor
    public init(title: String,
                value: Bool,
                rowType: SettingsRow,
                titleColor: UIColor = .label,
                titleFont: UIFont = .withType(.Default(.Normal))) {
        self.title = title
        self.value = value
        self.rowType = rowType
        self.titleColor = titleColor
        self.titleFont = titleFont
    }
    
    // MARK: - Update
    public func update(value: Bool) {
        self.value = value
    }
}

import Utility
import UIKit
import Combine

public final class AppSettingsSwitchModel: Modelable {
    // MARK: Properties
    let title: String
    var value: Bool
    var rowType: SettingsRow
    var titleColor: UIColor = k_settingsCellTextColor
    var titleFont: UIFont = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)!
    
    // MARK: - Constructor
    public init(title: String,
                value: Bool,
                rowType: SettingsRow,
                titleColor: UIColor = k_settingsCellTextColor,
                titleFont: UIFont = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)!) {
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

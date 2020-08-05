import Foundation
import UIKit
import Utility
import SnapKit

public final class AppSettingsStorageCell: UITableViewCell, Cellable {
    
    // MARK: Properties
    public typealias ModelType = AppSettingsModel

    lazy private var storageSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = AppStyle.Colors.loaderColor.color
        slider.maximumTrackTintColor = .placeholderText
        slider.thumbTintColor = .clear
        slider.isEnabled = false
        return slider
    }()
    
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = k_settingsCellTextColor
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)
        return label
    }()
    
    // MARK: - Constructor
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        addBottomBorderWithColor(color: k_borderColor, width: 1.0)
    }
    
    // MARK: - Setup UI
    private func buildLayout() {
        backgroundColor = .systemBackground
        
        [
            storageSlider,
            titleLabel
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        })
        
        storageSlider.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16.0)
            make.trailing.equalToSuperview().offset(-16.0)
            make.bottom.equalToSuperview().inset(16.0)
        }
        
        titleLabel.snp.makeConstraints { [weak self] (make) in
            guard let safeSelf = self else {
                return
            }
            make.top.equalToSuperview().offset(16.0)
            make.trailing.equalTo(safeSelf.storageSlider.snp.trailing)
            make.bottom.equalTo(safeSelf.storageSlider.snp.top).inset(8.0)
        }
    }
    
    // MARK: - Configuration
    public func configure(with model: AppSettingsModel) {
        titleLabel.text = model.title
        titleLabel.textAlignment = model.titleAlignment
        accessoryType = model.showDetailIndicator ? .disclosureIndicator : .none
        selectionStyle = model.selectable ? .default : .none
        
        textLabel?.font = model.titleFont
        textLabel?.textColor = model.titleColor
    }
}

import UIKit
import Utility
import SnapKit

public final class EncryptionCell: UITableViewCell, Cellable {
    
    // MARK: Properties
    public typealias ModelType = Encryption
    var onChangeValue: ((Bool) -> Void)?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)
        label.textColor = k_cellTitleTextColor
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var encryptionSwitch: UISwitch = {
        let eSwitch = UISwitch()
        eSwitch.onTintColor = AppStyle.Colors.loaderColor.color
        eSwitch.addTarget(self, action: #selector(onToggleSwitch(_:)), for: .valueChanged)
        return eSwitch
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.tintColor = AppStyle.Colors.loaderColor.color
        activity.hidesWhenStopped = true
        activity.isHidden = true
        return activity
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
            titleLabel,
            encryptionSwitch,
            activityIndicatorView
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        })
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(16.0)
            make.centerY.equalToSuperview()
        }
        
        encryptionSwitch.snp.makeConstraints { [weak self] (make) in
            guard let safeSelf = self else { return }
            make.trailing.equalToSuperview().offset(-16.0)
            make.centerY.equalTo(safeSelf.titleLabel.snp.centerY)
        }
        
        activityIndicatorView.snp.makeConstraints { [weak self] (make) in
            guard let safeSelf = self else { return }
            make.trailing.equalTo(safeSelf.encryptionSwitch.snp.leading).offset(-8.0)
            make.centerY.equalTo(safeSelf.encryptionSwitch)
        }
    }
    
    // MARK: - Actions
    @objc
    private func onToggleSwitch(_ sender: UISwitch) {
        onChangeValue?(sender.isOn)
    }
    
    func revert() {
        let existingState = encryptionSwitch.isOn
        encryptionSwitch.setOn(!existingState, animated: true)
    }
    
    // MARK: - Configuration
    public func configure(with model: Encryption) {
        titleLabel.text = model.title
        encryptionSwitch.isOn = model.isOn
        encryptionSwitch.isEnabled = model.isEnabled
    }
}

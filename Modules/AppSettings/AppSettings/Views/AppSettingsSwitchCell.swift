import UIKit
import Utility

class AppSettingsSwitchCell: UITableViewCell, Modelable {

    // MARK: Properties
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = k_settingsCellTextColor
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)
        return label
    }()
    
    lazy private var settingsSwitch: UISwitch = {
        let aSwitch = UISwitch()
        aSwitch.onTintColor = AppStyle.Colors.loaderColor.color
        return aSwitch
    }()
    
    private var viewModel: AppSettingsSwitchModel?
    
    var onChangeValue: ((Bool) -> Void)?
    
    // MARK: - Constructor
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Setup UI
    private func buildLayout() {
        backgroundColor = .systemBackground
        
        [
            titleLabel,
            settingsSwitch
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        })

        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16.0)
            make.trailing.equalToSuperview().offset(-16.0)
            make.centerY.equalToSuperview()
        }
        
        settingsSwitch.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-16.0)
            make.centerY.equalToSuperview()
        }
        
        settingsSwitch.addTarget(self, action: #selector(onChangeValue(_:)), for: .valueChanged)
    }
    
    // MARK: - Actions
    @objc
    private func onChangeValue(_ sender: UISwitch) {
        viewModel?.update(value: sender.isOn)
        onChangeValue?(sender.isOn)
    }

    // MARK: - Configuration
    public func configure(with model: Modelable) {
        guard let model = model as? AppSettingsSwitchModel else {
            fatalError("Couldn't Find AppSettingsModel")
        }
        titleLabel.text = model.title
        titleLabel.textAlignment = .left
        accessoryType = .none
        selectionStyle = .none
        titleLabel.font = model.titleFont
        titleLabel.textColor = model.titleColor
        
        settingsSwitch.isOn = model.value
        
        viewModel = model
    }
}

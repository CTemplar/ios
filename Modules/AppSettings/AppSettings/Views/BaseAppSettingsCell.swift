import UIKit
import Utility

class BaseAppSettingsCell: UITableViewCell, Cellable {

    // MARK: Properties
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = k_settingsCellTextColor
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)
        return label
    }()
    
    lazy private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = k_settingsCellSecondaryTextColor
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)
        return label
    }()

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        accessoryType = .none
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Setup UI
    // MARK: - Setup UI
    private func buildLayout() {
        backgroundColor = .systemBackground
        
        [
            titleLabel
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        })

        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16.0)
            make.trailing.equalToSuperview().offset(-16.0)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - Configuration
    public func configure(with model: Modelable) {
        guard let model = model as? AppSettingsModel else {
            fatalError("Couldn't Find AppSettingsModel")
        }
        
        titleLabel.text = model.title
        titleLabel.textAlignment = model.titleAlignment
        subtitleLabel.textAlignment = .right
        accessoryType = model.showDetailIndicator ? .disclosureIndicator : .none
        selectionStyle = model.selectable ? .default : .none
        titleLabel.font = model.titleFont
        titleLabel.textColor = model.titleColor
        
        if model.subtitle?.isEmpty == false {
            addSubview(subtitleLabel)
            subtitleLabel.text = model.subtitle
            subtitleLabel.snp.makeConstraints { [weak self] (make) in
                guard let safeSelf = self else {
                    return
                }
                make.centerY.equalTo(safeSelf.titleLabel)
                make.trailing.equalToSuperview().inset(model.showDetailIndicator ? 32.0 : 16.0)
            }
        }
    }
}

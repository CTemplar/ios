import Foundation
import Utility
import UIKit
import Combine

class ComposeMailFromEmailCell: UITableViewCell, Cellable {
    // MARK: Properties
    private let emailIdTextLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let prefixLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)
        label.textColor = .systemGray
        label.textAlignment = .left
        label.text = SenderPrefixMode.from.localized
        return label
    }()
    
    private lazy var chevronButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = k_cellTitleTextColor
        button.setImage(#imageLiteral(resourceName: "downArrow"), for: .normal)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    private (set) var model: ComposeMailFromEmailModel!
    
    private var anyCancellables = Set<AnyCancellable>()
    
    var onTapDown: ((String) -> Void)?
    
    // MARK: - Constructor
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        anyCancellables.forEach({ $0.cancel() })
        anyCancellables.removeAll()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        emailIdTextLabel.text = ""
    }
    
    // MARK: - Setup
    private func setupObservers() {
        model.$mailId
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (email) in
                self?.emailIdTextLabel.text = email
            })
            .store(in: &anyCancellables)
    }
    
    private func buildLayout() {
        // Do any additional setup after loading the view.
        backgroundColor = .systemBackground
        
        selectionStyle = .none
        
        chevronButton.setImage(SenderPrefixMode.from.chevronImage, for: .normal)
        chevronButton.addTarget(self, action: #selector(onTapDown(_:)), for: .touchUpInside)

        [
            chevronButton,
            prefixLabel,
            emailIdTextLabel
        ].forEach({
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })

        chevronButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-16.0)
            make.centerY.equalToSuperview()
            make.width.equalTo(30.0)
        }
        
        prefixLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16.0)
            make.centerY.equalToSuperview()
        }
        
        prefixLabel.snp.contentHuggingHorizontalPriority = 750.0
        
        emailIdTextLabel.snp.makeConstraints { [weak self] (make) in
            guard let safeSelf = self else { return }
            make.leading.equalTo(safeSelf.prefixLabel.snp.trailing)
            make.trailing.equalTo(safeSelf.chevronButton.snp.leading).offset(-4.0)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(.medium)
        }
    }
    
    // MARK: - Actions
    @objc
    private func onTapDown(_ sender: Any) {
        onTapDown?(emailIdTextLabel.text ?? "")
    }
    
    // MARK: - Configuration
    func configure(with model: Modelable) {
        guard let model = model as? ComposeMailFromEmailModel else {
            fatalError("Couldn't type cast ComposeMailEmailModel")
        }
        
        self.model = model
        
        setupObservers()
        
        layoutIfNeeded()
    }
}

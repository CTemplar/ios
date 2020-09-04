import Foundation
import UIKit
import SnapKit
import Utility

public final class InboxViewerSubjectCell: UITableViewCell, Cellable {
    // MARK: Properties
    private (set) var model: Subject?
    
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = AppStyle.CustomFontStyle.Bold.font(withSize: 16.0)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    lazy private var starButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "StarOff"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "StarOn"), for: .selected)
        button.isSelected = false
        button.contentMode = .scaleAspectFit
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(onTapStar(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy private var securedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "SecureOn")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy private var protectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "ProtectOn").withTintColor(UITraitCollection.current.userInterfaceStyle == .dark ?
            .white :
            k_contactsBarTintColor
        )
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.tintColor = AppStyle.Colors.loaderColor.color
        activity.hidesWhenStopped = true
        return activity
    }()
    
    var onTapStar: ((Bool) -> Void)?
        
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
        removeBorder(toSide: .Bottom)
        addBottomBorderWithColor(color: k_borderColor, width: 1.0)
    }

    // MARK: - Setup UI
    private func buildLayout() {
        contentView.isUserInteractionEnabled = false
        selectionStyle = .none
        backgroundColor = .systemBackground
        
        let stackView = UIStackView(arrangedSubviews: [securedImageView, protectedImageView])
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        
        // Add subviews
        [
            titleLabel,
            stackView,
            starButton,
            activityIndicatorView
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        })
        
        activityIndicatorView.isHidden = true
        
        // Adding Constraints
        securedImageView.snp.makeConstraints { (make) in
            make.width.equalTo(16.0)
            make.height.equalTo(16.0)
        }
        
        protectedImageView.snp.makeConstraints { (make) in
            make.width.equalTo(16.0)
            make.height.equalTo(16.0)
        }
        
        titleLabel.snp.makeConstraints { [weak self] (make) in
            guard let safeSelf = self else {
                return
            }
            make.leading.equalToSuperview().offset(16.0)
            make.centerY.equalTo(safeSelf.snp.centerY)
        }
        
        stackView.snp.makeConstraints { [weak self] (make) in
            guard let safeSelf = self else {
                return
            }
            make.leading.equalTo(titleLabel.snp.trailing).offset(8.0)
            make.centerY.equalTo(safeSelf.titleLabel.snp.centerY)
            make.trailing.equalTo(safeSelf.starButton.snp.leading).offset(-8.0)
        }
        
        starButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-8.0)
            make.centerY.equalTo(stackView.snp.centerY)
            make.width.equalTo(30.0)
            make.height.equalTo(30.0)
        }
        
        activityIndicatorView.snp.makeConstraints { [weak self] (maker) in
            guard let safeSelf = self else {
                return
            }
            maker.center.centerX.centerY.equalTo(safeSelf.starButton)
        }
        
        layoutIfNeeded()
    }
    
    // MARK: - Configuration
    public func configure(with model: Modelable) {
        guard let model = model as? Subject else {
            fatalError("Couldn't Find Subject")
        }
        
        titleLabel.text = model.title
        
        if !model.isProtected {
            protectedImageView.isHidden = true
        }
        
        if !model.isSecured {
            securedImageView.isHidden = true
        }
        
        starButton.isSelected = model.isStarred
        
        self.model = model
    }
    
    // MARK: - Actions
    @objc
    private func onTapStar(_ sender: UIButton) {
        activityIndicatorView.startAnimating()
        sender.isHidden = true
        onTapStar?(sender.isSelected)
    }
    
    func update(isStarred: Bool) {
        activityIndicatorView.stopAnimating()
        starButton.isHidden = false
        self.model?.update(isStarred: isStarred)
        starButton.isSelected = isStarred
    }
}

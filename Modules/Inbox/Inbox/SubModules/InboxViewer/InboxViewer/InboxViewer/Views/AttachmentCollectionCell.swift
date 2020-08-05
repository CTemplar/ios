import UIKit
import Utility
import SnapKit

public class AttachmentCollectionCell: UICollectionViewCell, Cellable {
    // MARK: - Properties
    public typealias ModelType = MailAttachment
    
    private lazy var roundedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = k_attachmentCellColor
        view.layer.cornerRadius = 3.0
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 0.3
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 12.0)
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .left
        label.clipsToBounds = true
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var attachmentTypeLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.CustomFontStyle.Bold.font(withSize: 9.0)
        label.layer.cornerRadius = 2.0
        label.layer.masksToBounds = false
        label.clipsToBounds = true
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        addSubview(roundedBackgroundView)
        
        [
            titleLabel,
            attachmentTypeLabel
        ].forEach({
            roundedBackgroundView.addSubview($0)
        })
        
        // Add constraints
        roundedBackgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            )
        }
        
        titleLabel.snp.makeConstraints { [weak self] (make) in
            guard let safeSelf = self else { return }
            make.leading.equalToSuperview().offset(8.0)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8.0)
            make.bottom.equalTo(safeSelf.attachmentTypeLabel).inset(4.0)
        }
        
        attachmentTypeLabel.snp.makeConstraints { [weak self] (make) in
            guard let safeSelf = self else { return }
            make.width.equalTo(32.0)
            make.height.equalTo(12.0)
            make.leading.equalTo(safeSelf.titleLabel.snp.leading)
            make.bottom.equalToSuperview().inset(12.0)
        }
    }
    
    // MARK: - Configuration
    public func configure(with model: MailAttachment) {
        titleLabel.text = model.attachmentTitle
        attachmentTypeLabel.text = model.attachmentType.rawValue.uppercased()
        attachmentTypeLabel.backgroundColor = model.attachmentType.color
    }
}

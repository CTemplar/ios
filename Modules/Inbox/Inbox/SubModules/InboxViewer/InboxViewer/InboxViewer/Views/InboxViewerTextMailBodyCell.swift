import Foundation
import UIKit
import Utility

public final class InboxViewerTextMailBodyCell: UITableViewCell, Cellable {
    
    // MARK: Properties
    private let mailBodyTextLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
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
        
        addSubview(mailBodyTextLabel)
        
        mailBodyTextLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 8.0, left: 8.0, bottom: 4.0, right: 8.0)
            )
        }
    }
    
    // MARK: - Configuration
    public func configure(with model: Modelable) {
        guard let model = model as? TextMail else {
            fatalError("Couldn't Find TextMail")
        }
        mailBodyTextLabel.text = model.content.replacingOccurrences(of: "<br>", with: "\n")
    }
}

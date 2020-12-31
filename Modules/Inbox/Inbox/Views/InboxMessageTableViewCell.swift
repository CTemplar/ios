import Foundation
import UIKit
import SwipeCellKit
import Utility
import Networking

class InboxMessageTableViewCell: SwipeTableViewCell, Cellable {
    
    // MARK: IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel! {
        didSet {
            countLabel.backgroundColor = k_redColor
            countLabel.font = .withType(.ExtraSmall(.Bold))
        }
    }
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.textColor = .systemGray2
            timeLabel.font = .withType(.Small(.Bold))
        }
    }
    @IBOutlet weak var isReadView: UIView! {
        didSet {
            isReadView.cornerRadius = isReadView.frame.size.width / 2.0
        }
    }
    @IBOutlet weak var isSecuredImageView: UIImageView! {
        didSet {
            isSecuredImageView.tintColor = k_mailboxTextColor
        }
    }
    @IBOutlet weak var isStaredImageView: UIImageView! {
        didSet {
            isStaredImageView.tintColor = .systemYellow
        }
    }
    @IBOutlet weak var moreActionButton: UIButton!
    @IBOutlet weak var hasAttachmentImageView: UIImageView!
    @IBOutlet weak var timerlabelsView: UIView!
    @IBOutlet weak var leftlabelView: UIView!
    @IBOutlet weak var rightlabelView: UIView!
    
    // MARK: Properties
    struct Model: Modelable {
        let message: EmailMessage
        let subjectEncrypted: Bool
    }
    
    var onTapMore: (() -> Void)?
   
    lazy var formatterService: FormatterService = {
        return UtilityManager.shared.formatterService
    }()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectedBackgroundView = UIView()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        moreActionButton.isHidden = isEditing
        containerView.shadowColor = traitCollection.userInterfaceStyle == .dark ? UIColor.black.withAlphaComponent(0.2) : UIColor.systemGray5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.selectedBackgroundView?.backgroundColor = .clear
    }
    
    // MARK: - Configuration
    func configure(with model: Modelable) {
        let model = model as! Model
        setupLabelsAndImages(message: model.message, subjectEncrypted: model.subjectEncrypted)
    }
    
    // MARK: - Actions
    @IBAction func onTapMore(_ sender: Any) {
        onTapMore?()
    }
}

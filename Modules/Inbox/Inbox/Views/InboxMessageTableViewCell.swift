import Foundation
import UIKit
import MGSwipeTableCell
import Utility
import Networking

class InboxMessageTableViewCell: MGSwipeTableCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var headMessageLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var encryptedSubjectLabel: UILabel!
    @IBOutlet weak var isSelectedImageView: UIImageView!
    @IBOutlet weak var isReadImageView: UIImageView!
    @IBOutlet weak var isSecuredImageView: UIImageView!
    @IBOutlet weak var isStaredImageView: UIImageView!
    @IBOutlet weak var hasAttachmentImageView: UIImageView!
    @IBOutlet weak var badgesView: UIView!
    @IBOutlet weak var timerlabelsView: UIView!
    @IBOutlet weak var leftlabelView: UIView!
    @IBOutlet weak var rightlabelView: UIView!
    @IBOutlet weak var encryptedSubjectView: UIView!
    @IBOutlet weak var senderLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var isSelectedImageTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var isSelectedImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var dotImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var dotImageTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var countLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var countLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var badgesViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var timerlabelsViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftlabelViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightlabelViewWidthConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    var cellWidth: CGFloat = 0.0
   
    lazy var formatterService: FormatterService = {
        return UtilityManager.shared.formatterService
    }()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Setup
    func setupCellWithData(message: EmailMessage,
                           header: String,
                           subjectEncrypted: Bool,
                           isSelectionMode: Bool,
                           isSelected: Bool,
                           frameWidth: CGFloat) {
        
        cellWidth = frameWidth
        setupLabelsAndImages(message: message, header: header, subjectEncrypted: subjectEncrypted)
        setupConstraints(message: message, isSelectionMode: isSelectionMode)
        isSelectedImageView.image = isSelected ? #imageLiteral(resourceName: "checkedBoxDark") : #imageLiteral(resourceName: "roundDark")
    }
    
    func isShortNeed(message: EmailMessage) -> Bool {
        var short = false
        var leftLabelShowing = false
        
        if Device.IS_IPHONE_5 {
            short = true
        } else {
            if message.delayedDelivery != nil || message.deadManDuration != nil {
                leftLabelShowing = true
            }
            
            if message.destructDay != nil {
                if leftLabelShowing {
                    short = true
                }
            }
        }
        return short
    }
}

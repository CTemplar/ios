import Foundation
import UIKit
import Utility
import Networking

class ContactTableViewCell: UITableViewCell {
    // MARK: IBOutlets
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var checkImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkImageViewTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(contact: Contact, isSelectionMode: Bool, isSelected: Bool, foundText: String) {        
        if let userName = contact.contactName {
            let subjectAttributedString = NSMutableAttributedString(string: userName)
            let range = subjectAttributedString.foundRangeFor(lowercasedString: userName.lowercased(), textToFind: foundText)
            _ = subjectAttributedString.setBackgroundColor(range: range, color: k_foundTextBackgroundColor)
            self.nameLabel.attributedText = subjectAttributedString
            self.initialsLabel.text = formatInitials(name: userName)
        } else {
            self.nameLabel.text = Strings.Contacts.unknownName.localized
            self.initialsLabel.text = formatInitials(name: Strings.Contacts.unknownName.localized)
        }
        
        if let email = contact.email {
            let subjectAttributedString = NSMutableAttributedString(string: email)
            let range = subjectAttributedString.foundRangeFor(lowercasedString: email.lowercased(), textToFind: foundText)
            _ = subjectAttributedString.setBackgroundColor(range: range, color: k_foundTextBackgroundColor)
            self.emailLabel.attributedText = subjectAttributedString           
        } else {
            self.emailLabel.text = Strings.Contacts.unknownEmail.localized
        }
        
        checkImageViewWidthConstraint.constant = isSelectionMode ? 22.0 : 0.0
        checkImageViewTrailingConstraint.constant = isSelectionMode ? 12.0 : 0.0

        checkImageView.image = isSelected ? #imageLiteral(resourceName: "checkedBoxDark") : #imageLiteral(resourceName: "roundDark")
        
        layoutIfNeeded()
    }
    
    func formatInitials(name: String) -> String {
        let initials = name.prefix(2)
        return String(initials).uppercased()
    }
}

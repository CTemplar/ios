import Foundation
import UIKit
import Utility
import Networking

class ContactTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectedBackgroundView = UIView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        selectedBackgroundView?.backgroundColor = .clear
    }
    
    // MARK: - Configuration
    func configure(with contact: Contact, foundText: String) {
        if let userName = contact.contactName {
            let subjectAttributedString = NSMutableAttributedString(string: userName)
            let range = subjectAttributedString.foundRangeFor(lowercasedString: userName.lowercased(), textToFind: foundText)
            _ = subjectAttributedString.setBackgroundColor(range: range, color: k_foundTextBackgroundColor)
            nameLabel.attributedText = subjectAttributedString
            initialsLabel.text = formatInitials(name: userName)
        } else {
            nameLabel.text = Strings.Contacts.unknownName.localized
            initialsLabel.text = formatInitials(name: Strings.Contacts.unknownName.localized)
        }
        
        if let email = contact.email {
            let subjectAttributedString = NSMutableAttributedString(string: email)
            let range = subjectAttributedString.foundRangeFor(lowercasedString: email.lowercased(), textToFind: foundText)
            _ = subjectAttributedString.setBackgroundColor(range: range, color: k_foundTextBackgroundColor)
            emailLabel.attributedText = subjectAttributedString
        } else {
            emailLabel.text = Strings.Contacts.unknownEmail.localized
        }
    }

    private func formatInitials(name: String) -> String {
        let initials = name.prefix(2)
        return String(initials).uppercased()
    }
}

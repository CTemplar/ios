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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - UI Setup
    func setupCellWithData(contact: Contact, isSelected: Bool, foundText: String) {
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
        
        selectionStyle = isSelected ? .none : .default
        
        isUserInteractionEnabled = isSelected == false
        
        accessoryType = isSelected ? .checkmark : .none
        
        self.isSelected = isSelected
        
        layoutIfNeeded()
    }
    
    func formatInitials(name: String) -> String {
        let initials = name.prefix(2)
        return String(initials).uppercased()
    }
}

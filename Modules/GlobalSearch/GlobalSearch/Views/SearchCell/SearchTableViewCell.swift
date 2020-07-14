import Foundation
import UIKit
import Utility
import Networking
import Inbox

class SearchTableViewCell: UITableViewCell {
    // MARK: IBOutlets
    @IBOutlet weak var folderNameBackground: UIView!
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var hasAttachmentImageView: UIImageView!
    @IBOutlet weak var isSecuredImageView: UIImageView!
    @IBOutlet weak var isStaredImageView: UIImageView!
    @IBOutlet weak var folderNameLabelWidthConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    private let formatterService = UtilityManager.shared.formatterService
    private var folders: [Folder] = []
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        folderNameLabel.text = ""
        subjectLabel.text = ""
        dateLabel.text = ""
        senderLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Setup Data
    func setupCellWithData(withFolders folders: [Folder],
                           message: EmailMessage,
                           foundText: String) {
        self.folders = folders
        
        setupSubjectData(fromMessage: message, foundText: foundText)
        
        setupSenderData(fromMessage: message, foundText: foundText)
        
        if let createdDate = message.createdAt {            
            if  let date = formatterService.formatStringToDate(date: createdDate) {
                dateLabel.text = formatterService.formatCreationDate(date: date, short: true)
            }
        }
        
        isSecuredImageView.image = message.isProtected == true ? #imageLiteral(resourceName: "SecureOn") : #imageLiteral(resourceName: "SecureOff")
        
        isStaredImageView.image = message.starred == true ? #imageLiteral(resourceName: "StarOn") : #imageLiteral(resourceName: "StarOff")
        
        hasAttachmentImageView.isHidden = message.attachments?.isEmpty == true
        
        if let folderName = message.folder {
            folderNameLabel.text = folderName
            let folderNameWidthString = folderName.widthOfString(usingFont: folderNameLabel.font)
            let combinedWidth = folderNameWidthString + SearchConstant.FolderNameLabelOffset.rawValue
            
            if combinedWidth > SearchConstant.FolderNameLabelMaxWidth.rawValue {
                folderNameLabelWidthConstraint.constant = SearchConstant.FolderNameLabelMaxWidth.rawValue
            } else {
                folderNameLabelWidthConstraint.constant = combinedWidth
            }
                
            let color = folderColor(folderName: folderName)
            
            folderNameBackground.backgroundColor = color
            
            folderNameLabel.textColor = color == k_mainInboxColor ? k_mainFolderTextColor : .white
        }
        
        layoutIfNeeded()
    }
    
    private func setupSubjectData(fromMessage message: EmailMessage, foundText: String) {
        if let subject = message.subject {
            let subjectAttributedString = NSMutableAttributedString(string: subject,
                                                                    attributes: [.foregroundColor: k_cellSubTitleTextColor])
            let range = subjectAttributedString.foundRangeFor(lowercasedString: subject.lowercased(),
                                                              textToFind: foundText)
            _ = subjectAttributedString.setBackgroundColor(range: range,
                                                           color: k_foundTextBackgroundColor)
            subjectLabel.attributedText = subjectAttributedString
        }
    }
    
    private func setupSenderData(fromMessage message: EmailMessage, foundText: String) {
        if let sender = message.sender {
            let senderAttributedString = NSMutableAttributedString(string: sender,
                                                                   attributes: [.foregroundColor: k_cellTitleTextColor])
            let range = senderAttributedString.foundRangeFor(lowercasedString: sender.lowercased(),
                                                             textToFind: foundText)
            _ = senderAttributedString.setBackgroundColor(range: range,
                                                          color: k_foundTextBackgroundColor)
            senderLabel.attributedText = senderAttributedString
        }
    }
    
    private func folderColor(folderName: String) -> UIColor {
        guard let _ = Menu(rawValue: folderName) else {
            return customFolderColor(folderName: folderName)
        }
        return k_mainInboxColor
    }
    
    private func customFolderColor(folderName: String) -> UIColor {
        guard let folder = folders.first(where: { $0.folderName == folderName }),
            let hexColorCode = folder.color else {
            return k_mainInboxColor
        }
        let colorValue = UIColor.hexToColor(hexColorCode)
        return colorValue
    }
}

//
//  AliasCell.swift
//  AppSettings
//


import UIKit
import Utility
import Networking

class AliasCell: UITableViewCell {

    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var emailLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    func configure(model: Mailbox) {
        self.emailLbl.textColor = UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
        self.statusBtn.setTitleColor(UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black, for: .normal)

        self.emailLbl.text = model.email
        self.statusBtn.isUserInteractionEnabled = true
        if (model.isDefault == true) {
            self.statusBtn.setTitle("", for: .normal)
            self.statusBtn.setTitleColor(.clear, for: .normal)
            self.statusBtn.setImage(UIImage(named: "redCheck"), for: .normal)
            self.statusBtn.isUserInteractionEnabled = false
            self.statusBtn.tintColor = .red
            self.emailLbl.textColor = .red
        }
        else {
            self.statusBtn.setImage(nil, for: .normal)
            if(model.isEnabled == true) {
                self.statusBtn.setTitle("Disable", for: .normal)
            }
            else {
                self.statusBtn.setTitle("Enable", for: .normal)
            }
        }
    }
    
}

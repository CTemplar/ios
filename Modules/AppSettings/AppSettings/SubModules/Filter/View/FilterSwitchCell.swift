//
//  FilterSwitchCell.swift
//

import UIKit

class FilterSwitchCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    private var model:FilterModel?
    weak var folderModel:FilterModel?
    weak var parentController: AddFilterVC?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(model: FilterModel) {
        self.model = model
        self.switchBtn.isOn = model.isSelected
        self.switchBtn.tag = self.model?.type?.rawValue ?? 0
    }
    
    @IBAction func switchValueChanged(_ sender: Any) {
        if (self.switchBtn.isOn == true) {
            if (self.switchBtn.tag == self.model?.type?.rawValue  ?? 0) {
                if (self.model?.type == FilterHeaders.moveTo) {
                    if (self.folderModel != nil) {
                        self.folderModel?.isSelected = true
                    }
                }
                self.model?.isSelected = true
            }
        }
        else {
            if (self.switchBtn.tag == self.model?.type?.rawValue ?? 0) {
                if (self.model?.type == FilterHeaders.moveTo) {
                    if (self.folderModel != nil) {
                        self.folderModel?.isSelected = false
                        self.folderModel?.title = ""
                        self.parentController?.view.endEditing(true)
                        self.parentController?.tableView.reloadData()
                    }
                }
                self.model?.isSelected = false
            }
        }
    }
}

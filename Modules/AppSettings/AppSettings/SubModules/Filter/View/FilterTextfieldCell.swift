//
//  FilterTextfieldCell.swift



import UIKit
import Networking
import Utility

class FilterTextfieldCell: UITableViewCell {

    @IBOutlet weak var textFieldBackImageView: UIImageView!
    @IBOutlet weak var downArrow: UIImageView!
    @IBOutlet weak var textField: UITextField!
    private var picker = UIPickerView()
    private var pickerArray = [ConditionValues]()
    private var folderPickerArray = [Folder]()
    private var model:FilterModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
   
        self.textFieldBackImageView.layer.cornerRadius = 7
        self.textFieldBackImageView.layer.masksToBounds = true
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.textField.backgroundColor = .clear
        self.textField.textColor = .black
    }
    
    func configure(model: FilterModel, isdropDown: Bool) {
        self.model = model
        self.textField.tag =  model.type?.rawValue ?? 0
        self.textField.text = model.title
        if (model.type == FilterHeaders.folder) {
            self.textField.delegate = self
        }
        else {
            self.textField.delegate = nil
        }
        if (model.dropDownAvail() == false) {
            self.textField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(self.doneButtonClickedFromPicker))

            self.downArrow.isHidden = false
            if(model.type == FilterHeaders.folder) {
                self.folderPickerArray = model.folderArrayTypes
            }
            else {
                self.pickerArray = model.typeArray()
            }
           
            self.createPickerView(tag:model.type?.rawValue ?? 0)
        }
        else {
            self.addEventForEditingChange()
            self.downArrow.isHidden = true
            self.textField.inputView = nil
        }
        
        textField.attributedPlaceholder = NSAttributedString(string: model.placeholder,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    @objc func doneButtonClickedFromPicker() {
        if (self.textField.tag == picker.tag) {
            let seletedIndex = self.picker.selectedRow(inComponent: 0)
            if (picker.tag == FilterHeaders.folder.rawValue) {
                self.model?.saveTitleForFolder(index: seletedIndex, tag: picker.tag)
                if(self.model?.folderArrayTypes.count ?? 0 > seletedIndex) {
                    self.textField.text = self.model?.title
                }
            }
            else {
                self.model?.saveTitle(index: seletedIndex, tag: picker.tag)
                self.model?.saveValue(index: seletedIndex, tag: picker.tag)
                if(self.model?.arrTypes.count ?? 0 > seletedIndex) {
                    self.textField.text = self.model?.title
                }
            }
        }
        //print("Done clicked")
    }
    
    @objc func doneButtonClicked() {
        if (self.textField.tag == picker.tag) {
        }
    }
    private func createPickerView(tag: Int) {
        let pickerView = UIPickerView()
        pickerView.tag = tag
        pickerView.delegate = self
        self.textField.inputView = pickerView
        self.picker = pickerView
    }
    
    private func addEventForEditingChange() {
      self.removeEventForEditingChange()
        self.textField.addTarget(
            self, action: #selector(self.textFieldEditingDidChanged(_:)), for: .editingChanged)
    }

    private func removeEventForEditingChange() {
        self.textField.removeTarget(
        self, action: #selector(self.textFieldEditingDidChanged(_:)), for: .editingChanged)
    }
    
    @objc private func textFieldEditingDidChanged(_ sender: UITextField) {
        if (sender.tag == self.model?.type?.rawValue) {
            self.model?.title = sender.text ?? ""
        }
    }
}

extension FilterTextfieldCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // number of session
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (model?.type == FilterHeaders.folder) {
            return self.folderPickerArray.count
        }
        
        return self.pickerArray.count//typeList.count // number of dropdown items
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (model?.type == FilterHeaders.folder) {
            return self.folderPickerArray[row].folderName
        }
        return self.pickerArray[row].frontValue//typeList[row] // dropdown item
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel?
           if view == nil {  //if no label there yet
               pickerLabel = UILabel()
               //color the label's background
            pickerLabel?.backgroundColor = UIColor.clear
         }
        if (model?.type == FilterHeaders.folder) {
            let titleData = self.folderPickerArray[row].folderName ?? ""
         let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor:traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black])
            pickerLabel!.attributedText = myTitle
         pickerLabel!.textAlignment = .center
        }
        else {
            let titleData = String(self.pickerArray[row].frontValue)
         let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor:traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black])
            pickerLabel!.attributedText = myTitle
         pickerLabel!.textAlignment = .center
        }
        return pickerLabel ?? UILabel()
            
       }
}

extension FilterTextfieldCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (model?.type == FilterHeaders.folder) {
            if (model?.isSelected == false) {
                return false
            }
        }
        return true
    }
}

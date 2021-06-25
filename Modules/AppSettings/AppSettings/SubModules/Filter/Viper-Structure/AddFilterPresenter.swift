//
//  AddFilterPresenter.swift
//  AppSettings
//


import Foundation
import UIKit
import Utility
import Networking
import Signup

final class AddFilterPresenter:NSObject {
    // MARK: Properties
    private (set) weak var parentController: AddFilterVC?
    private (set) var interactor: AddFilterInteractor?
    var folderModel:[Folder]?
    var filterModel:FilterDataModel?
    var tableView: UITableView?

    // MARK: - Constructor
    init(parentController: AddFilterVC?) {
        
        self.parentController = parentController
        self.filterModel = FilterDataModel(parentController:self.parentController!)
        self.tableView = self.parentController?.tableView
        self.interactor = AddFilterInteractor(parentController: self.parentController!)
        
    }
    
    func setupUI() {
        self.tableView?.register(UINib(nibName: FilterSwitchCell.className,
                                       bundle: Bundle(for: FilterSwitchCell.self)),
                                 forCellReuseIdentifier: FilterSwitchCell.className)
        self.tableView?.register(UINib(nibName: FilterTextfieldCell.className,
                                       bundle: Bundle(for: FilterTextfieldCell.self)),
                                 forCellReuseIdentifier: FilterTextfieldCell.className)
        
        self.parentController?.submitBtn.layer.cornerRadius = 9
        self.parentController?.submitBtn.layer.masksToBounds = true
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.interactor?.filterList()
    }
    
    
    
    
    func updateFilter(filter:Filter) {
        self.parentController?.delegate?.updateFilter(filter: filter)
        self.parentController?.dismiss(animated: true, completion: nil)
    }
    
    func refreshFilter(filter:Filter) {
        self.parentController?.delegate?.refreshFilter()
        self.parentController?.dismiss(animated: true, completion: nil)
    }
    
    func setupTableView() {
    }
    func submitBtnClicked() {
        if(self.checkValidation() == true) {
          var filter = Filter()
            filter.setFilterData(name: self.filterModel?.array[0][0].title ?? "" , parameter:self.filterModel?.array[1][1].selectedValue?.serverValue ?? "" , condition:self.filterModel?.array[1][0].selectedValue?.serverValue ?? "" , filterText:self.filterModel?.array[1][2].title ?? "" , folder:self.filterModel?.array[2][1].title ?? "" , moveTo:self.filterModel?.array[2][0].isSelected ?? true , read:self.filterModel?.array[2][2].isSelected ?? true , starred:self.filterModel?.array[2][3].isSelected ?? true, id: self.parentController?.filterModel?.id ?? 0)
            if (self.parentController?.isForEdit == true) {
                self.interactor?.editFilter(filter: filter)
            }
            else {
                self.interactor?.addFilter(filter: filter)
            }
           
           
        }
        else {
            let alert = UIAlertController(title: "", message: "Fill all the fields!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: Strings.Button.okButton.localized, style: .cancel))
            self.parentController?.present(alert, animated: true)
        }
        
    }
    private func checkValidation()-> Bool {
        if let array = self.filterModel?.array {
            for (index, item) in array.enumerated() {
                if (index == 0) {
                    for name in item {
                        if (name.title == "") {
                            return false
                        }
                    }
                }
                else if (index == 1) {
                    for name in item {
                        if(name.title == "") {
                            return false
                        }
                    }
                }
                else {
                    for (index, name) in item.enumerated() {
                        if (index == 1) {
                            if (name.title == "") {
                                return false
                            }
                        }
                    }
                }
            }
        }
        return true
    }
}


extension AddFilterPresenter: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filterModel?.array.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.filterModel?.array[section].count ?? 0
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 140
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
        let headerlabel =  UILabel(frame: CGRect(x: 15, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
        headerlabel.font = UIFont.systemFont(ofSize: 16)
        headerlabel.backgroundColor = .clear
        headerView.backgroundColor = UIColor(named: "unreadMessageColor")
        if (section == 0) {
            headerlabel.text = FilterSectionHeader.name
        }
        else if (section == 1) {
            headerlabel.text = FilterSectionHeader.condition
        }
        else {
            headerlabel.text = FilterSectionHeader.action
        }
        headerView.addSubview(headerlabel)
      return headerView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        guard let model = self.filterModel?.array[indexPath.section][indexPath.row] else  {
            return UITableViewCell()
        }
        if (indexPath.section == 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterTextfieldCell .className, for: indexPath) as? FilterTextfieldCell
            else { return UITableViewCell() }
            cell.textField.placeholder = model.placeholder
            cell.configure(model: model, isdropDown: false)
            return cell
        }
        else if (indexPath.section == 1) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterTextfieldCell .className, for: indexPath) as? FilterTextfieldCell
            else { return UITableViewCell() }
            cell.textField.placeholder = model.placeholder
            if (indexPath.row == 2) {
                cell.configure(model: model, isdropDown: false)
            }
            else {
                cell.configure(model: model, isdropDown: true)
            }

            return cell
        }
        else {
            if(indexPath.row == 1) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterTextfieldCell .className, for: indexPath) as? FilterTextfieldCell
                else { return UITableViewCell() }
                cell.textField.placeholder = model.placeholder
                cell.configure(model: model, isdropDown: true)
                return cell
            }
            else if (indexPath.row == 0) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterSwitchCell .className, for: indexPath) as? FilterSwitchCell
                else { return UITableViewCell() }
                cell.titleLbl.text = model.placeholder
                cell.configureCell(model: model)
                guard let model = self.filterModel?.array[indexPath.section][1] else  {
                    return cell
                }
                cell.folderModel = model
                cell.parentController = self.parentController
                return cell
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterSwitchCell .className, for: indexPath) as? FilterSwitchCell
                else { return UITableViewCell() }
                cell.titleLbl.text = model.placeholder
                cell.configureCell(model: model)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


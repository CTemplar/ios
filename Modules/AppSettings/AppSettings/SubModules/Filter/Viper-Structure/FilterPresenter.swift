//
//  FilterPresenter.swift
//  AppSettings
//


import Foundation
import UIKit
import Utility
import Networking
import Signup
import SwipeCellKit

final class FilterPresenter:NSObject {
    // MARK: Properties
    private (set) weak var parentController: FilterVC?
    private (set) var interactor: FilterInteractor?
    var filterModel:[Filter]?
    var folderModel:[Folder]?
    var tableView: UITableView?
    lazy var defaultOptions: SwipeOptions = {
        return SwipeOptions()
    }()
    
    // MARK: - Constructor
    init(parentController: FilterVC?) {
        self.parentController = parentController
        self.tableView = self.parentController?.tableView
        self.tableView?.tableFooterView = UIView()
        self.interactor = FilterInteractor(parentController: parentController)
        
    }
    
    func setupUI() {
        self.tableView?.register(UINib(nibName: FilterCell.className,
                                       bundle: Bundle(for: FilterCell.self)),
                                 forCellReuseIdentifier: FilterCell.className)
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.interactor?.filterList()
        self.interactor?.getFolders()
    }
    
    // MARK: - ViewController Update
    func filterList(filter: [Filter]) {
        self.filterModel = filter
        self.tableView?.reloadData()
    }
    // MARK: - Interactor Updates
    func update(folders: [Folder]) {
        self.folderModel = folders
    }
    func refreshFilterAfterDelete() {
        self.interactor?.filterList(true)
    }
    func setupTableView() {
    }
    
    func editFilter(indexPath: IndexPath) {
        let addFilter: AddFilterVC = UIStoryboard(storyboard: .filter,
                                                  bundle: Bundle(for: AddFilterVC.self)
        ).instantiateViewController()
        addFilter.folderModel = self.folderModel
        addFilter.delegate = self
        addFilter.isForEdit = true
        addFilter.filterModel = self.filterModel?[indexPath.row]
        self.parentController?.present(addFilter, animated: true, completion: nil)
    }
    func deleteFilter(indexPath: IndexPath) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete the filter!", preferredStyle: .alert)

        let loginAction = UIAlertAction(title: Strings.Button.okButton.localized, style: .default) { [unowned self] (_) in
            DispatchQueue.main.async {
                self.interactor?.deleteFilter(id: String(self.filterModel?[indexPath.row].id ?? 0))
            }
        }

        alert.addAction(UIAlertAction(title: Strings.Button.cancelButton.localized, style: .cancel))
        loginAction.isEnabled = true
        alert.addAction(loginAction)
        self.parentController?.present(alert, animated: true)
        
    }
}


extension FilterPresenter: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.filterModel?.count ?? 0
    }
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 140
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let model = self.filterModel?[indexPath.row] else {
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.className, for: indexPath) as? FilterCell
        else { return UITableViewCell() }
        cell.titleLbl.text = model.name
        cell.selectionStyle = .none
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //    private func tableView(tableView: UITableView,
    //                   canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    //        return true
    //    }
    
    //    func tableView(tableView: UITableView,
    //                   commitEditingStyle editingStyle: UITableViewCellEditingStyle,
    //                   forRowAtIndexPath indexPath: NSIndexPath) {
    //        if (editingStyle == UITableViewCellEditingStyle.Delete) {
    //            // handle delete (by removing the data from your array and updating the tableview)
    //        }
    //    }
    //    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
    //            // delete item at indexPath
    //        }
    //
    //        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
    //            // share item at indexPath
    //        }
    //
    //        edit.backgroundColor = UIColor.blue
    //
    //        return [edit, delete]
    //    }
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
//            self.deleteFilter(indexPath: indexPath)
//            print("index path of delete: \(indexPath)")
//            completionHandler(true)
//        }
//
//        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, sourceView, completionHandler) in
//            DispatchQueue.main.async {
//                self.editFilter(indexPath: indexPath)
//            }
//            //            print("index path of delete: \(indexPath)")
//            completionHandler(true)
//        }
//        let swipeAction = UISwipeActionsConfiguration(actions: [delete, edit])
//        swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
//        return swipeAction
//    }
}


extension FilterPresenter: AddFilterDelegate {
    func updateFilter(filter: Filter) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.filterModel?.append(filter)
            self.tableView?.reloadData()
        }
    }
    func refreshFilter() {
        self.interactor?.filterList(true)
    }
}

extension FilterPresenter {
    func rightSwipeAction(for indexPath: IndexPath) -> [SwipeAction]? {
        guard self.filterModel?.count ?? 0 > indexPath.row else {
            return nil
        }
                
        let deleteAction = SwipeAction(style: .default, title: nil) { [weak self] (action, indexPath) in
            self?.deleteFilter(indexPath: indexPath)
        }
        
        deleteAction.hidesWhenSelected = true
        configure(action: deleteAction, with: "DELETE", backgroundColor: .red)
        
        
        let editAction = SwipeAction(style: .default, title: nil) { [weak self] (action, indexPath) in
            self?.editFilter(indexPath: indexPath)
        }
        
        editAction.hidesWhenSelected = true
        configure(action: editAction, with: "EDIT", backgroundColor: .blue)
        
        return [editAction, deleteAction]
    }
    
    func configure(action: SwipeAction, with text: String, backgroundColor: UIColor) {
        action.title = text
        action.backgroundColor = backgroundColor
        action.textColor = .black
        action.font = .withType(.ExtraSmall(.Bold))
        action.transitionDelegate = ScaleTransition.default
    }
}

extension FilterPresenter: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

            return rightSwipeAction(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        options.transitionStyle = defaultOptions.transitionStyle
        options.buttonSpacing = 4
        options.backgroundColor = .clear
        return options
    }
}


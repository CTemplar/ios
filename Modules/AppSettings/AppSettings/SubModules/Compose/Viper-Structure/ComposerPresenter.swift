//
//  ComposerPresenter.swift
//  AppSettings
//

import Foundation
import UIKit
import Utility
import Networking

class ComposerPresenter: NSObject {
    // MARK: Properties
    private (set) weak var parentController: ComposeVC?
    private (set) var interactor: ComposerInteractor?
    var tableView: UITableView?
    var user = UserMyself()
    var composerModel:ComposerDataModel?

    // MARK: - Constructor
    init(parentController: ComposeVC, user: UserMyself) {
        self.parentController = parentController
        self.tableView = self.parentController?.tableView
        self.user = user
        self.composerModel = ComposerDataModel(parentController: parentController, user: self.user)
        self.tableView?.tableFooterView = UIView()
        self.interactor = ComposerInteractor(parentController: parentController)
    }
    
    func setupUI() {
        self.tableView?.register(UINib(nibName: ComposerCell.className,
                                       bundle: Bundle(for: ComposerCell.self)),
                                 forCellReuseIdentifier: ComposerCell.className)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.parentController?.saveBtn.layer.cornerRadius = 9
        self.parentController?.saveBtn.layer.masksToBounds = true
    }
    
    func saveBtnClicked() {
        var size = ""
        if (self.composerModel?.array[2].title == ComposerSize.forteen) {
            size = "14"
        }
        else {
            size = self.composerModel?.array[2].title.replacingOccurrences(of: "px", with: "") ?? ""
        }
        
        let composer = Composer.composerData(model: [self.composerModel?.array[0].title.lowercased() ?? "", self.composerModel?.array[1].title.lowercased() ?? "", size, self.composerModel?.array[3].title.lowercased() ?? ""])
        self.interactor?.addComposer(composer: composer, id: self.user.settings.settingsID ?? 0)
    }
    
    func updateData(settings:Settings) {
        NotificationCenter.default.post(name: .updateUserSettingsNotificationID, object: nil, userInfo: nil)
        self.parentController?.navigationController?.popViewController(animated: true)
        self.parentController?.navigationController?.navigationBar.isHidden = false
    }
}
extension ComposerPresenter: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.composerModel?.array.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let model = self.composerModel?.array[indexPath.row] else {
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ComposerCell.className, for: indexPath) as? ComposerCell
        else { return UITableViewCell() }
//        cell.textField.text = model.title
        cell.selectionStyle = .none
        cell.configure(model: model, isdropDown: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
   
}

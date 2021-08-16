//
//  AliasPresenter.swift
//  AppSettings
//


import Foundation
import UIKit
import Utility
import Networking
import Signup

final class AliasPresenter {
    // MARK: Properties
    private (set) weak var parentController: AliasController?
    private (set) var interactor: AliasInteractor?
    private (set) var formatter: FormatterService?
    
    // MARK: - Constructor
    init(parentController: AliasController?) {
        self.parentController = parentController
        self.formatter = FormatterService()
        self.interactor = AliasInteractor(parentController: parentController)
       
    }
    
    // MARK: - ViewController Update
    func updateUserExistanceText(by userExistance: UserExistance) {
        self.parentController?.update(by: userExistance)
    }
    
    func setupTableView() {
        self.interactor?.tableView = self.parentController?.tableView
        self.interactor?.setupTableView()
    }
    
    // MARK: - Sub-Controllers Config
    func changeButtonState(button: UIButton, disabled: Bool) {
        if disabled {
            button.isEnabled = false
            button.alpha = 0.6
        } else {
            button.isEnabled = true
            button.alpha = 1.0
        }
    }

}

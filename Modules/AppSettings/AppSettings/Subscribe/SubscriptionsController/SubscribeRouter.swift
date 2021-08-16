//
//  SubscribeRouter.swift
//  AppSettings
//


import UIKit

struct SubscribeRouter {
    // MARK: Properties
    let parentController: SubscriptionListController
    
    // MARK: - Actions
    func showInboxSideMenu() {
        parentController.sideMenuController?.revealMenu()
    }
}

struct SubscribeDataSource {
    // MARK: Properties
    let parentViewController: SubscriptionListController
    let navigationTitle: String
}

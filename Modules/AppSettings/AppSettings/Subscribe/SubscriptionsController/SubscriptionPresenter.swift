//
//  SubscriptionPresenter.swift
//  AppSettings
//


import UIKit

struct SubscriptionPresenter {
    var parentController: SubscriptionListController?

    func setupNavigationLeftItem() {
        let emptyButton = UIBarButtonItem(image: UIImage(), style: .done, target: self, action: nil)
        if UIDevice.current.orientation.isLandscape {
            parentController?.navigationItem.leftBarButtonItem = emptyButton
        } else {
            parentController?.navigationItem.leftBarButtonItem = parentController?.leftBarButtonItem
        }
    }
}

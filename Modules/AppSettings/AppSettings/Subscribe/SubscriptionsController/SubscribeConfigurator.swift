//
//  SubscribeConfigurator.swift
//  AppSettings
//


import UIKit
import Networking

final class SubscribeConfigurator {
    func configure(with controller: SubscriptionListController, user: UserMyself) {
        let router = SubscribeRouter(parentController: controller)
        let presenter = SubscriptionPresenter(parentController: controller)
        controller.setup(presenter: presenter)
        controller.setup(router: router)
        controller.setup(user: user)
    }
}

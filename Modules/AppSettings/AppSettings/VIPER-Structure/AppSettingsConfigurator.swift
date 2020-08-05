import Foundation
import Networking

final class AppSettingsConfigurator {
    func configure(with settingsController: AppSettingsController, user: UserMyself) {
        let router = AppSettingsRouter(parentController: settingsController)
        let presenter = AppSettingsPresenter(parentController: settingsController)
        settingsController.setup(presenter: presenter)
        settingsController.setup(router: router)
        settingsController.setup(user: user)
    }
}

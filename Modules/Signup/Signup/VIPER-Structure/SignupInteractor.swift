import Foundation
import Utility
import Networking
import UIKit

final class SignupInteractor: HashingService {
    private var viewController: SignupPageViewController
    private var presenter: SignupPresenter
    private var apiService: APIService
    var keychainService: KeychainService?
    
    // MARK: - Constructor
    init(viewController: SignupPageViewController,
         presenter: SignupPresenter,
         apiService: APIService,
         keychainService: KeychainService) {
        self.viewController = viewController
        self.presenter = presenter
        self.apiService = apiService
        self.keychainService = keychainService
    }
    
    func signupUser(using model: SignupModel) {
        
        (viewController.orderedViewControllers.last as? SignupRecoveryEmailViewController)?.startLoader()
        
        generateCryptoInfo(for: model.userName, password: model.password) { [weak self] in
            guard let info = try? $0.get() else {
                (self?.viewController.orderedViewControllers.last as? SignupRecoveryEmailViewController)?.stopLoader()

                self?.viewController.showAlert(with: Strings.Signup.signupError.localized,
                                                message: Strings.Signup.somethingWentWrong.localized,
                                                buttonTitle: Strings.Button.closeButton.localized)
                return
            }
            
            let details = SignupDetails(userName: model.userName,
                                        password: info.hashedPassword,
                                        privateKey: info.userPgpKey.privateKey,
                                        publicKey: info.userPgpKey.publicKey,
                                        fingerprint: info.userPgpKey.fingerprint,
                                        language: "English",
                                        recoveryEmail: model.recoveryEmail,
                                        inviteCode: model.invitationCode)

            NetworkManager.shared.networkService.signUp(with: details) { result in
                if (try? result.get()) != nil {
                    self?.keychainService?.saveUserCredentials(userName: model.userName, password: model.password)
                }
                self?.handleNetwork(responce: result)
                
                (self?.viewController.orderedViewControllers.last as? SignupRecoveryEmailViewController)?.stopLoader()
            }
        }
    }
    
    func handleNetwork(responce: AppResult<TokenResult>) {
        switch responce {
        case .success(let value):
            keychainService?.saveToken(token: value.token)
            NotificationCenter.default.post(name: Notification.Name(GeneralConstant.updateInboxMessagesNotificationID), object: nil, userInfo: nil)
            sendAPNDeviceToken()
            viewController.router?.showInboxScreen()
        case .failure(let error):
            viewController.showAlert(with: Strings.Signup.signupError.localized,
                                     message: error.localizedDescription,
                                     buttonTitle: Strings.Button.closeButton.localized)
        }
    }
    
    func checkUser(userName: String) {
        if !presenter.formatter.validateNameLench(enteredName: userName) {
            presenter.updateUserExistanceText(by: .unAvailable)
            return
        }
        
        NetworkManager.shared.networkService.checkUser(name: userName) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let value):
                    DPrint("checkUser success value:", value)
                    self.presenter.updateUserExistanceText(by: value.exists ? .unAvailable : .available)
                case .failure(let error):
                    DPrint("checkUser error:", error)
                    self.presenter.updateUserExistanceText(by: .unAvailable)
                }
            }
        }
    }
    
    func sendAPNDeviceToken() {
        guard let deviceToken = keychainService?.getAPNDeviceToken(), !deviceToken.isEmpty  else { return }
        NetworkManager.shared.networkService.send(deviceToken: deviceToken) { _ in }
    }
}

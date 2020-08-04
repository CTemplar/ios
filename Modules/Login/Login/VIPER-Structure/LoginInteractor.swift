import Foundation
import Networking
import Utility
import UIKit

final class LoginInteractor: Configurable, HashingService {
    // MARK: Properties
    typealias AdditionalConfig = LoginInteractorConfig
    
    private let apiService = NetworkManager.shared.apiService
    private let keychainService = UtilityManager.shared.keychainService
    private var loginDetails: LoginDetails!
    private var shouldRememberCredentials = false
    
    enum LoginInteractorConfig: Configuration {
        case loginDetails(LoginDetails)
        case showHideLoader((Bool) -> Void)
        case showAlert((_ title: String, _ message: String) -> Void)
        case screenTransitionOnSuccess(() -> Void)
        case showOTPValidation((LoginResult, String) -> Void)
    }
    
    private var onToggleLoader: ((Bool) -> Void)?
    private var onShowAlert: ((_ title: String, _ message: String) -> Void)?
    private var onScreenTransition: (() -> Void)?
    private var showOTPValidation: ((LoginResult, String) -> Void)?
    
    // MARK: - Constructor
    init(with configs: [LoginInteractorConfig]) {
        for config in configs {
            switch config {
            case .loginDetails(let model):
                self.loginDetails = model
            case .showHideLoader(let loaderClosure):
                self.onToggleLoader = loaderClosure
            case .showAlert(let alertClosure):
                self.onShowAlert = alertClosure
            case .screenTransitionOnSuccess(let transitionClosure):
                self.onScreenTransition = transitionClosure
            case .showOTPValidation(let otpClosure):
                self.showOTPValidation = otpClosure
            }
        }
        
        if self.loginDetails == nil {
            fatalError("Login Details cannot be nil")
        }
    }
    
    // MARK: - Updates
    func updateRememberStatus(by status: Bool) {
        shouldRememberCredentials = status
    }
    
    func update(userName: String) {
        loginDetails.update(userName: userName)
    }
    
    func update(password: String) {
        loginDetails.update(password: password)
    }
    
    func update(twoFACode: String) {
        loginDetails.update(twoFACode: twoFACode)
    }

    // MARK: - User Authentication
    func authenticateUser(fromPresenter presenter: UIViewController? = nil) {
        let trimmedUsername = trimUserName(loginDetails.userName)
        
        if let presenter = presenter {
            Loader.start(presenter: presenter)
        } else {
            onToggleLoader?(true)
        }
        
        generateHashedPassword(for: trimmedUsername, password: loginDetails.password) { [weak self] (result) in
            guard let self = self else {
                return
            }
            
            guard let value = try? result.get() else {
                if let presenter = presenter {
                    Loader.stop(in: presenter)
                    presenter.showAlert(with: Strings.Login.loginError.localized,
                                        message: Strings.Signup.somethingWentWrong.localized,
                                        buttonTitle: Strings.Button.okButton.localized
                    )
                } else {
                    self.onToggleLoader?(false)
                    self.onShowAlert?(Strings.Login.loginError.localized,
                                      Strings.Signup.somethingWentWrong.localized
                    )
                }
                return
            }
            
            // Create Temporary login details struct
            let loginDetails = LoginDetails(userName: self.loginDetails.userName, password: value, twoFACode: self.loginDetails.twoFACode)
            
            NetworkManager.shared.networkService.loginUser(with: loginDetails) { (result) in
                DispatchQueue.main.async {
                    self.handleNetwork(responce: result,
                                       username: self.loginDetails.userName,
                                       password: self.loginDetails.password,
                                       presenter: presenter)
                }
            }
        }
    }
    
    private func trimUserName(_ userName: String) -> String {
        var trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let substrings = trimmedName.split(separator: "@")
        if let domain = substrings.last {
            if domain == Domain.main.rawValue || domain == Domain.dev.rawValue || domain == Domain.devOld.rawValue {
                if let name = substrings.first {
                    trimmedName = String(name)
                }
            }
        }
        return trimmedName
    }
    
    // MARK: - API Response handler
    func handleNetwork(responce: AppResult<LoginResult>,
                       username: String,
                       password: String,
                       presenter: UIViewController?) {
        
        if presenter != nil {
            Loader.stop(in: presenter)
        } else {
            onToggleLoader?(false)
        }
        
        switch responce {
        case .success(let value):
            if let token = value.token {
                keychainService.saveToken(token: token)
            }
            
            keychainService.saveRememberMeValue(rememberMe: shouldRememberCredentials)
            keychainService.saveUserCredentials(userName: username, password: password)
            keychainService.saveTwoFAvalue(isTwoFAenabled: value.isTwoFAEnabled)
            
            if value.isTwoFAEnabled, value.token == nil {
                // Show OTP Validation screen
                showOTPValidation?(value, password)
            } else {
                NotificationCenter.default.post(name: .updateInboxMessagesNotification, object: nil, userInfo: nil)
                
                sendAPNDeviceToken()

                presenter?.dismiss(animated: true, completion: nil)
                // Show Inbox
                onScreenTransition?()
            }
        case .failure(let error):
            if let presenter = presenter {
                presenter.showAlert(with: Strings.Login.loginError.localized,
                                    message: error.localizedDescription,
                                    buttonTitle: Strings.Button.okButton.localized)
            } else {
                onShowAlert?(Strings.Login.loginError.localized, error.localizedDescription)
            }
        }
    }
    
    private func sendAPNDeviceToken() {
        let deviceToken = keychainService.getAPNDeviceToken()
        guard deviceToken.isEmpty == false else { return }
        NetworkManager.shared.networkService.send(deviceToken: deviceToken) { _ in }
    }
}

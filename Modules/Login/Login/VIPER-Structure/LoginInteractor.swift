import Foundation
import Networking
import Utility

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
    }
    
    private var onToggleLoader: ((Bool) -> Void)?
    private var onShowAlert: ((_ title: String, _ message: String) -> Void)?
    private var onScreenTransition: (() -> Void)?
    
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

    // MARK: - User Authentication
    func authenticateUser() {
        let trimmedUsername = trimUserName(loginDetails.userName)
        onToggleLoader?(true)
        generateHashedPassword(for: trimmedUsername, password: loginDetails.password) { [weak self] (result) in
            guard let self = self else {
                return
            }
            
            guard let value = try? result.get() else {
                self.onToggleLoader?(false)
                self.onShowAlert?(Strings.Login.loginError.localized, Strings.Signup.somethingWentWrong.localized)
                return
            }
            
            // Create Temporary login details struct
            let loginDetails = LoginDetails(userName: self.loginDetails.userName, password: value)
            
            NetworkManager.shared.networkService.loginUser(with: loginDetails) { (result) in
                self.handleNetwork(responce: result, username: self.loginDetails.userName, password: self.loginDetails.password)
                self.onToggleLoader?(false)
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
    func handleNetwork(responce: AppResult<LoginResult>, username: String, password: String) {
        switch responce {
        case .success(let value):
            if let token = value.token {
                keychainService.saveToken(token: token)
            }
            
            keychainService.saveRememberMeValue(rememberMe: shouldRememberCredentials)
            keychainService.saveUserCredentials(userName: username, password: password)
            
            NotificationCenter.default.post(name: .updateInboxMessagesNotification, object: nil, userInfo: nil)
            
            sendAPNDeviceToken()
            
            // Show Inbox
            onScreenTransition?()
        case .failure(let error):
            onShowAlert?(Strings.Login.loginError.localized, error.localizedDescription)
        }
    }
    
    private func sendAPNDeviceToken() {
        let deviceToken = keychainService.getAPNDeviceToken()
        guard deviceToken.isEmpty == false else { return }
        NetworkManager.shared.networkService.send(deviceToken: deviceToken) { _ in }
    }
}

import Foundation
import Utility
import Networking

final class ForgetPasswordInteractor: HashingService {
    
    // MARK: Properties
    private (set) weak var viewController: ForgetPasswordViewController?
    private (set) weak var presenter: ForgetPasswordPresenter?
    private let apiService = NetworkManager.shared.apiService
    private let keychainService = UtilityManager.shared.keychainService
    private var shouldShowLoader: ((Bool) -> Void)
    private var onDisplayAlert: ((String, String) -> Void)
    private var onCompletion: (() -> Void)?
    
    // MARK: - Constructor
    init(viewController: ForgetPasswordViewController?,
         presenter: ForgetPasswordPresenter?,
         shouldShowLoader: @escaping ((Bool) -> Void),
         onDisplayAlert: @escaping ((String, String) -> Void),
         onCompletion: (() -> Void)?) {
        self.viewController = viewController
        self.presenter = presenter
        self.shouldShowLoader = shouldShowLoader
        self.onDisplayAlert = onDisplayAlert
        self.onCompletion = onCompletion
    }
    
    // MARK: - API Calls
    func recoveryPasswordCode(userName: String, recoveryEmail: String) {
        shouldShowLoader(true)
        NetworkManager.shared.networkService.recoveryPasswordCode(for: userName,
                                                                  recoveryEmail: recoveryEmail) {
                                                                    self.shouldShowLoader(false)
                                                                    guard case .failure(let error) = $0 else {
                                                                        self.onCompletion?()
                                                                        return
                                                                    }
                                                                    self.onDisplayAlert(Strings.ForgetPassword.passwordCodeError.localized, error.localizedDescription)
                                                                    
        }
    }
    
    func resetPassword(userName: String, password: String, resetPasswordCode: String, recoveryEmail: String) {
        shouldShowLoader(true)
        generateCryptoInfo(for: userName, password: password) { [weak self] in
            guard let info = try? $0.get() else {
                self?.shouldShowLoader(false)
                self?.onDisplayAlert(Strings.ForgetPassword.passwordResetError.localized, Strings.Signup.somethingWentWrong.localized)
                return
            }
            let details = ResetPasswordDetails(resetPasswordCode: resetPasswordCode,
                                               userName: userName,
                                               password: info.hashedPassword,
                                               privateKey: info.userPgpKey.privateKey,
                                               publicKey: info.userPgpKey.publicKey,
                                               fingerprint: info.userPgpKey.fingerprint,
                                               recoveryEmail: recoveryEmail)
            NetworkManager.shared.networkService.resetPassword(with: details) { result in
                if (try? result.get()) != nil {
                    self?.keychainService.saveUserCredentials(userName: userName, password: password)
                }
                self?.handleNetwork(responce: result)
                self?.shouldShowLoader(false)
            }
        }
    }
    
    // MARK: - Response Handler
    func handleNetwork(responce: AppResult<TokenResult>) {
        switch responce {
        case .success:
            onCompletion?()
        case .failure(let error):
            onDisplayAlert(Strings.ForgetPassword.passwordResetError.localized, error.localizedDescription)
        }
    }
}

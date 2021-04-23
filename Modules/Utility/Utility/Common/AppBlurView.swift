import UIKit
import LocalAuthentication

public enum BiometricType {
    case none
    case touch
    case face
    
    public var displayIdentifier: String {
        switch self {
        case .face:
            return "Face ID"
        case .touch:
            return "Touch ID"
        case .none:
            return ""
        }
    }
}

public extension LAContext {
    static func getAvailableBiometricType() -> BiometricType {
        let context = LAContext()

        if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            return .none
        }
        switch(context.biometryType) {
        case .none:
            return .none
        case .touchID:
            return .touch
        case .faceID:
            return .face
        @unknown default:
            fatalError()
        }
    }
}

public class AppBlurView: UIVisualEffectView {
    public func triggerBiometric(onSuccess: @escaping (() -> Void),
                                 onFailure: @escaping ((String) -> Void)) {
        guard UserDefaults.standard.bool(forKey: biometricEnabled) else {
            onSuccess()
            return
        }
        
        let localAuthenticationContext = LAContext()

        guard LAContext.getAvailableBiometricType() != .none else {
            onSuccess()
            return
        }
                
        localAuthenticationContext.localizedFallbackTitle = Strings.BiometricError.usePasscode.localized
        
        let reason = Strings.BiometricError.authText.localized
        
        localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication,
                                                  localizedReason: reason) { (success, evaluateError) in
            if success {
                onSuccess()
            } else {
                guard let error = evaluateError else {
                    return
                }
                let message = self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code)
                onFailure(message)
            }
        }
    }

    private func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        var message = ""
        switch errorCode {
        case LAError.authenticationFailed.rawValue:
            message = Strings.BiometricError.authenticationFailed.localized
        case LAError.appCancel.rawValue:
            message = Strings.BiometricError.appCancel.localized
        case LAError.invalidContext.rawValue:
            message = Strings.BiometricError.invalidContext.localized
        case LAError.notInteractive.rawValue:
            message = Strings.BiometricError.notInteractive.localized
        case LAError.passcodeNotSet.rawValue:
            message = Strings.BiometricError.passcodeNotSet.localized
        case LAError.systemCancel.rawValue:
            message = Strings.BiometricError.systemCancel.localized
        case LAError.userCancel.rawValue:
            message = Strings.BiometricError.userCancel.localized
        case LAError.userFallback.rawValue:
            message = Strings.BiometricError.userFallback.localized
        case LAError.biometryNotAvailable.rawValue:
            message = Strings.BiometricError.biometryNotAvailable.localized
        case LAError.biometryLockout.rawValue:
            message = Strings.BiometricError.biometryLockout.localized
        case LAError.biometryNotEnrolled.rawValue:
            message = Strings.BiometricError.biometryNotEnrolled.localized
        default:
            message = Strings.BiometricError.defaultBiometricError.localized
        }
        return message
    }
}

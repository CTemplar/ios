import Foundation
import Combine
import Utility

final class SetPasswordViewModel {
    private let formatterService = UtilityManager.shared.formatterService
    
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var passwordHint: String = ""
    @Published var days: String = "5"
    @Published var hours: String = "0"
    
    lazy var validatedPassword =
        Publishers
            .CombineLatest($password, $confirmPassword)
            .map { [unowned self] in
                self.formatterService.validatePasswordLench(enteredPassword: $0) &&
                    self.formatterService.comparePasswordsLench(enteredPassword: $1, password: $0) &&
                    self.formatterService.passwordsMatched(choosedPassword: $0, confirmedPassword: $1)
        }
        .eraseToAnyPublisher()
    
    func expirationTime() -> Int? {
        if let daysInt = Int(days), let hoursInt = Int(hours) {
            let overallHours = (daysInt * 24) + hoursInt
            if overallHours <= 120 && overallHours > 0 {
                return overallHours
            }
        }
        return nil
    }
}

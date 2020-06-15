import Foundation

struct SignupModel {
    // MARK: Properties
    private (set) var userName: String
    private (set) var password: String
    private (set) var recoveryEmail: String
    private (set) var invitationCode: String
    
    // MARK: - Constructor
    init() {
        self.userName = ""
        self.password = ""
        self.recoveryEmail = ""
        self.invitationCode = ""
    }
    
    // MARK: - Updates
    mutating func update(userName: String) {
        self.userName = userName
    }
    
    mutating func update(password: String) {
        self.password = password
    }
    
    mutating func update(recoveryEmail: String) {
        self.recoveryEmail = recoveryEmail
    }
    
    mutating func update(invitationCode: String) {
        self.invitationCode = invitationCode
    }
}

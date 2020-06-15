import Foundation

public class UtilityManager {
    public static var shared = UtilityManager()
    public private (set) var formatterService: FormatterService
    public private (set) var keychainService: KeychainService
    
    private init() {
        formatterService = FormatterService()
        keychainService = KeychainService()
    }
    
    public lazy var pgpService: PGPService = {
        let service = PGPService(keychainService: self.keychainService)
        return service
    }()
}

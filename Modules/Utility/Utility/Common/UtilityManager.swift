import Foundation
import Reachability
import Combine


public class UtilityManager {
    public static var shared = UtilityManager()
    public private (set) var formatterService: FormatterService
    public private (set) var keychainService: KeychainService
    private var reachability: Reachability?
    public private (set) var subject = PassthroughSubject<Bool, Never>()
    
    private init() {
        formatterService = FormatterService()
        keychainService = KeychainService()
    } 
    
    public lazy var pgpService: PGPService = {
        let service = PGPService(keychainService: self.keychainService)
        return service
    }()
    
    // MARK: - Reachability
    public func setupReachability() {
        reachability = try? Reachability()
        
        reachability?.whenReachable = { [weak self] (reachability) in
            self?.subject.send(true)
        }
        
        reachability?.whenUnreachable = { [weak self] (_) in
            self?.subject.send(false)
        }
    }
    
    public func startReachability() {
        do {
            try reachability?.startNotifier()
        } catch {
            DPrint("Unable to start notifier")
        }
    }
    
    public func stopReachability() {
        reachability?.stopNotifier()
        subject.send(completion: .finished)
    }
}

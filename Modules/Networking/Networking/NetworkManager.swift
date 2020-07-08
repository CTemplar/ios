import Foundation
import Utility

public class NetworkManager {
    public static var shared = NetworkManager()
    
    private init() {
    }
    
    public lazy var restAPIService: RestAPIService = {
        let service = RestAPIService()
        return service
    }()
    
    public lazy var networkService: NetworkService = {
        let service = NetworkService()
        return service
    }()
    
    public lazy var apiService: APIService = {
        let service = APIService(restAPIService: NetworkManager.shared.restAPIService,
                                 keychainService: UtilityManager.shared.keychainService,
                                 pgpService: UtilityManager.shared.pgpService,
                                 formatterService: UtilityManager.shared.formatterService)
        return service
    }()
}

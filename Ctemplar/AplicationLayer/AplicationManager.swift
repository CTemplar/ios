//
//  AplicationManager.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

class ApplicationManager
{
    lazy var apiService: APIService = {
        
        let service = APIService()
        service.initialize()
        
        return service
        
    }()
    
    lazy var restAPIService: RestAPIService = {
        
        let service = RestAPIService()
        
        return service
        
    }()
    
    lazy var pgpService: PGPService = {
        
        let service = PGPService()
        
        return service
        
    }()
    
    lazy var keychainService: KeychainService = {
        
        let service = KeychainService()
        
        return service
        
    }()
}

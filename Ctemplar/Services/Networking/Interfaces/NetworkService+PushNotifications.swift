//
//  NetworkService+PushNotifications.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Alamofire
import Foundation

protocol PushNotificationsService {
    func send(deviceToken: String, completionHandler: @escaping Completion<Void>)
    func delete(deviceToken: String, completionHandler: @escaping Completion<Void>)
}

extension NetworkService: PushNotificationsService {
    func send(deviceToken: String, completionHandler: @escaping Completion<Void>) {
        perform(request: RouterPushNotifications.create(deviceToken: deviceToken),
                completionHandler: completionHandler)
    }
    
    func delete(deviceToken: String, completionHandler: @escaping Completion<Void>) {
        perform(request: RouterPushNotifications.delete(deviceToken: deviceToken),
                completionHandler: completionHandler)
    }
}

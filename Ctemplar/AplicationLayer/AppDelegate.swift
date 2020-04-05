//
//  AppDelegate.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import UserNotifications
import Firebase

typealias AppResult<T> = Result<T, Error>
typealias Completion<T> = (AppResult<T>) -> Void

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var applicationManager = AppManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
                  
        self.disableDarkMode()
        
        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")
        
        print("currentDeviceLanguageCode:", Locale.current.languageCode as Any)
        print("currentAppLanguage:", Locale.preferredLanguages[0])
        
        setupFirebase()
        self.registerForPushNotifications()
        
        application.applicationIconBadgeNumber = 0
        
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    private func setupFirebase() {
        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: filePath)
            else { return }
        FirebaseApp.configure(options: options)
        Messaging.messaging().delegate = self
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: - Push notifications
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
        
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNs device token: \(deviceTokenString)")
    }
       
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
    func saveAPNDeviceToken(_ token: String) {
        
        let keychainService = applicationManager.keychainService        
        keychainService.saveAPNDeviceToken(token)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        self.saveAPNDeviceToken(fcmToken)
        if !AppManager.shared.keychainService.getUserName().isEmpty {
            AppManager.shared.networkService.send(deviceToken: fcmToken) { _ in }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NotificationCenter.default.post(name: Notification.Name(k_updateInboxMessagesNotificationID), object: false, userInfo: nil)
        completionHandler([.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
            print("Notification data:\n\(userInfo)")
            if let messageId = Int(userInfo["gcm.notification.message_id"] as? String ?? "0") {
                var storyboardName = k_MainStoryboardName
                if Device.IS_IPAD {
                   storyboardName = k_MainStoryboardName_iPad
                }
                let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: k_MainViewControllerID) as! MainViewController
                mainViewController.messageID = messageId
                UIApplication.shared.keyWindow?.rootViewController = mainViewController
            }
        }
    }
}

extension AppDelegate {
    func disableDarkMode() {
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            window?.overrideUserInterfaceStyle = .light
        }
        #endif
    }
}

extension UIApplication {
    func getKeyWindow() -> UIWindow? {
        let newWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        return newWindow
    }
}


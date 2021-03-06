import Foundation

public extension Notification.Name {
    static let updateInboxMessagesNotification = Notification.Name("updateInboxMessagesNotification")
    static let updateUserDataNotificationID = Notification.Name("UpdateUserDataNotificationIdentifier")
    static let updateUserSettingsNotificationID = Notification.Name("UpdateUserSettingsNotificationIdentifier")
    static let updateInboxMessagesNotificationID = Notification.Name("updateInboxMessagesNotification")
    static let newMessagesNotificationID = Notification.Name("newMessagesNotificationID")
    static let attachUploadUpdateNotificationID = Notification.Name("attachUploadUpdateNotificationIdentifier")
    static let reloadViewControllerNotificationID = Notification.Name("ReloadViewControllerNotificationIdentifier")
    static let reloadViewControllerDataSourceNotificationID = Notification.Name("ReloadViewControllerDataSourceNotificationIdentifier")
    static let updateCustomFolderNotificationID = Notification.Name("UpdateCustomFoldersNotificationIdentifier")
    static let updateMessagesReadCountNotificationID = Notification.Name("updateMessagesReadCountNotification")
    static let logoutCompleteNotificationID = Notification.Name("logoutCompleteNotification")
    static let mailSentNotificationID = Notification.Name("mailSentNotification")
    static let mailSentErrorNotificationID = Notification.Name("mailSentErrorNotification")
    static let disableIQKeyboardManagerNotificationID = Notification.Name(rawValue: "disableIQKeyboardManagerNotification")
    static let showForceAppUpdateAlertNotificationID = Notification.Name(rawValue: "showForceAppUpdateAlertNotificationID")
}

//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import UserNotifications

struct NotificationTypes: OptionSet {
    let rawValue: Int
    static let none = NotificationTypes(rawValue: 0)
    static let badge = NotificationTypes(rawValue: 1 << 0)
    static let sound = NotificationTypes(rawValue: 1 << 1)
    static let alert = NotificationTypes(rawValue: 1 << 2)
}
extension UNUserNotificationCenter {
    
    func currentNotificationSettings() -> (types: NotificationTypes, authorisationStatus: UNAuthorizationStatus) {
        // todo implement
        
        var currentSettings: UNNotificationSettings?
        let semaphore = DispatchSemaphore(value: 0)
        getNotificationSettings { settings in
            currentSettings = settings
            semaphore.signal()
        }
        
        semaphore.wait()
        var types = NotificationTypes([.none])
        
        var authorizationStatus = UNAuthorizationStatus.notDetermined
        if let currentSettings = currentSettings {
            authorizationStatus = currentSettings.authorizationStatus
            if currentSettings.badgeSetting == UNNotificationSetting.enabled {
                types.insert(.badge)
            }
            if currentSettings.alertSetting == UNNotificationSetting.enabled {
                types.insert(.alert)
            }
            if currentSettings.soundSetting == UNNotificationSetting.enabled {
                types.insert(.sound)
            }
        }
        return (types, authorizationStatus)
    }
}

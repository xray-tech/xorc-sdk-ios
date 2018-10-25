//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import XrayKit
import UserNotifications

struct KeyValuesProvider: Encodable {
    let providers: [KeyValueProvider]
    
    func encode(to encoder: Encoder) throws {
        var encoder = encoder.singleValueContainer()
        var device =  [String: JSONValue]()
        
        providers.forEach { provider in
            device.merge(provider.json) { (current, _) in current }
        }
        try encoder.encode(device)
    }
    
    static func device() -> KeyValuesProvider {
        return KeyValuesProvider(providers: [
            TimeZoneProvider(),
            SystemInfoProvider(),
            NotificationStatusProvider()
            ])
    }
    
    static func environment(appId: String, appInstanceId: String) -> KeyValuesProvider {
        return KeyValuesProvider(providers: [
            XrayKitProvider(appId: appId, appInstanceId: appInstanceId),
            AppInfoProvider()
            ])
    }
}

/**
 The encodable request body of each request
 */
class NetworkModel: Encodable {
    let events: [EventNetworkModel]
    let device: KeyValuesProvider
    let environment: KeyValuesProvider
    
    init(events: [EventNetworkModel], environment: KeyValuesProvider) {
        self.events = events
        self.environment = environment
        self.device = KeyValuesProvider.device()
    }
}

/**
 Converts the event and session into the JSON Api format where the session and event keys need to be at the same level
 ```
 {
    "session_id" : "123",
    "name" : "app_open",
    "properties" : {
        "new" : "true"
    }
 }
 ```
 */
struct EventNetworkModel: Encodable {
    let session: Session
    let event: Event

    enum CodingKeys: String, CodingKey {
        case sessionId
        case id
        case name
        case properties
        case timestamp
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(session.sessionId.uuidString, forKey: .sessionId)
        try container.encode(String(event.sequenceId), forKey: .id)
        try container.encode(event.name, forKey: .name)
        try container.encode(String(Int(event.createdAt.timeIntervalSince1970)), forKey: .timestamp)
        try container.encode(event.properties, forKey: .properties)
    }
}

// MARK: - Parameter Providers

protocol KeyValueProvider {
    var json: [String: JSONValue] { get }
}

struct SingleKeyValueProvider: KeyValueProvider {
    let json: [String: JSONValue]
    
    init(key: String, value: JSONValue) {
        json = [key: value]
    }
}

struct TimeZoneProvider: KeyValueProvider {
    var json: [String: JSONValue] {
        var result = [String: JSONValue]()
        result["time_zone"] = JSONValue(NSTimeZone.system.identifier)
        
        // The [current localeIdentifier] might include some other properties such as
        // 'ar_SA@calendar=gregorian' so we use here explicitly only the language and country code to make the parsing
        // on the backend easier
        let locale = Locale.current as NSLocale
        if
            let country = locale.object(forKey: .countryCode) as? String,
            let language = locale.object(forKey: .languageCode) as? String {
            result["locale"] = JSONValue("\(language)_\(country)")
        }
        if let language = Locale.preferredLanguages.first {
            result["language"] = JSONValue(language)
        }
        
        return result
    }
}

struct SystemInfoProvider: KeyValueProvider {
    var json: [String: JSONValue] {
        let device = UIDevice.current
        var result = [String: JSONValue]()
        result["os_name"] = JSONValue(device.systemName)
        result["os_version"] = JSONValue(device.systemVersion)
        result["model"] = JSONValue(device.deviceModel())
        result["device_name"] = JSONValue(device.name)
        result["manufacturer"] = JSONValue("Apple")
        if let idfv = device.identifierForVendor {
            result["idfv"] = JSONValue(idfv.uuidString)
        }
        
        // todo
        result["ifa_tracking_enabled"] = false
        return result
    }
}

struct AppInfoProvider: KeyValueProvider {
    var json: [String: JSONValue] {
        let bundle = Bundle.main
        var result = [String: JSONValue]()
        
        result["app_version"] = JSONValue(bundle.version)
        result["app_build"] = JSONValue(bundle.build)
        result["app_store_id"] = JSONValue(bundle.bundleIdentifier ?? "")

        return result
    }
}

struct XrayKitProvider: KeyValueProvider {
    var json: [String: JSONValue]
    
    init(appId: String, appInstanceId: String) {
        
        let bundle = Bundle(for: Xray.self)
        json = [
            "app_id": JSONValue(appId),
            "app_instance_id": JSONValue(appInstanceId),
            "sdk_version": JSONValue(bundle.version)
        ]
    }
}

struct NotificationStatusProvider: KeyValueProvider {
    var json: [String: JSONValue] {
        var result = [String: JSONValue]()
        
        Thread.onMain {
            let settings = UNUserNotificationCenter.current().currentNotificationSettings()
            result["notification_registered"] = JSONValue(UIApplication.shared.isRegisteredForRemoteNotifications)
            result["notification_types"] = JSONValue(settings.types.rawValue)
            result["notification_auth_status"] = JSONValue(settings.authorisationStatus.rawValue)
        }
        
        return result
    }
}

extension UIDevice {
    
    func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in String.init(validatingUTF8: ptr) }
        }
        return modelCode ?? "unknown"
    }
}

// todo: move extensions
extension Bundle {
    var version: String {
        guard let infos = infoDictionary else { return "" }
        return (infos["CFBundleShortVersionString"] as? String ?? "")
    }
    
    var build: String {
        guard let infos = infoDictionary else { return "" }
        return (infos["CFBundleVersion"] as? String ?? "")
    }
}

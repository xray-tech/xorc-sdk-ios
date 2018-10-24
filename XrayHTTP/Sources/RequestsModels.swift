//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import XrayKit

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
            SystemInfoProvider()
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
    let events: [Event]
    let device: KeyValuesProvider
    let environment: KeyValuesProvider
    
    init(events: [Event], environment: KeyValuesProvider) {
        self.events = events
        self.environment = environment
        self.device = KeyValuesProvider.device()
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
        return ["time_zone": JSONValue(NSTimeZone.system.identifier)]
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

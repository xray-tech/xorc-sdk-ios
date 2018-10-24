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
}

class NetworkModel: Encodable {
    let events: [Event]
    let device: KeyValuesProvider
    
    init(events: [Event]) {
        self.events = events
        self.device = KeyValuesProvider.device()
    }
    
    enum CodingKeys: String, CodingKey {
        case events
        case device
    }
}

// MARK: - Parameter Providers

protocol KeyValueProvider {
    var json: [String: JSONValue] { get }
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

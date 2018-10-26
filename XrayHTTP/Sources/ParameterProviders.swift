//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import XrayKit
import UserNotifications


extension ParametersProvider {
    
    /// Helper method to create all the parameter for the "device" api json
    static func device() -> ParametersProvider {
        return ParametersProvider(providers: [
            TimeZoneParameterProvider(),
            SystemInfoParameterProvider(),
            NotificationStatusParameterProvider(),
            ScreenParameterProvider()
            ])
    }
    
    /// Helper method to create all the parameter for the "environment" api json
    static func environment(appId: String, appInstanceId: String) -> ParametersProvider {
        return ParametersProvider(providers: [
            XrayKitVersionParameterProvider(appId: appId, appInstanceId: appInstanceId),
            AppInfoParameterProvider()
            ])
    }
}
// MARK: - Parameter Providers

/**
    A key value providers provides a list of key values to be encoded and sent to the network
    It allows a composition of different parameters.
 */
protocol ParameterProvider {
    var json: [String: JSONValue] { get }
}

private struct SingleKeyValueProvider: ParameterProvider {
    let json: [String: JSONValue]
    
    init(key: String, value: JSONValue) {
        json = [key: value]
    }
}

private struct TimeZoneParameterProvider: ParameterProvider {
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

private struct SystemInfoParameterProvider: ParameterProvider {
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


private extension UIInterfaceOrientation {
    var toString: String {
        switch self {
        case .portrait: return "portrait"
        case .portraitUpsideDown:return "portrait_upside_down"
        case .landscapeLeft: return "landscape_left"
        case .landscapeRight: return "landscape_left"
        case .unknown: return "unknown"
        }
    }
}
private struct ScreenParameterProvider: ParameterProvider {
    
    var json: [String: JSONValue] {
        var result = [String: JSONValue]()
        var statusBarOrientation = UIInterfaceOrientation.portrait
        Thread.onMain {
            statusBarOrientation = UIApplication.shared.statusBarOrientation
        }
        let screen = UIScreen.main
        
        let width = Int(roundf(Float(screen.bounds.size.width * screen.scale)))
        let height = Int(roundf(Float(screen.bounds.size.height * screen.scale)))
        
        result["orientation"] = JSONValue(statusBarOrientation.toString)
        result["w"] = JSONValue(width)
        result["h"] = JSONValue(height)
        
        
        return result
    }
}

private struct ConnectionParameterProvider: ParameterProvider {
    var json: [String: JSONValue] {
        var result = [String: JSONValue]()
        //todo
        result["network_connection_type"] = "wifi"
        return result
    }
    
}

private struct AppInfoParameterProvider: ParameterProvider {
    var json: [String: JSONValue] {
        let bundle = Bundle.main
        var result = [String: JSONValue]()
        
        result["app_version"] = JSONValue(bundle.version)
        result["app_build"] = JSONValue(bundle.build)
        result["app_store_id"] = JSONValue(bundle.bundleIdentifier ?? "")
        
        return result
    }
}

private struct XrayKitVersionParameterProvider: ParameterProvider {
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

private struct NotificationStatusParameterProvider: ParameterProvider {
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

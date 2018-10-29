//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

protocol XrayStore {
    
    var appInstanceId: String? { get set }
    var deviceId: String? { get set }
    var apiToken: String? { get set }
    
}

class KeyValueStore: XrayStore {
    
    enum Keys: String {
        case appInstanceId
        case deviceId
        case apiToken
    }
    
    static func shared() -> KeyValueStore {
        return KeyValueStore()
    }
    
    static let prefix = "io.xorc."
    
    var appInstanceId: String? {
        get {
            return value(forKey: Keys.appInstanceId.rawValue)
        }
        
        set {
            if let value = newValue {
                save(value: value, forKey: Keys.appInstanceId.rawValue)
            }
        }
    }
    
    var deviceId: String? {
        get {
            return value(forKey: Keys.deviceId.rawValue)
        }
        
        set {
            if let value = newValue {
                save(value: value, forKey: Keys.deviceId.rawValue)
            }
        }
    }
    
    var apiToken: String? {
        get {
            return value(forKey: Keys.apiToken.rawValue)
        }
        
        set {
            if let value = newValue {
                save(value: value, forKey: Keys.apiToken.rawValue)
            }
        }
    }
    
    private func save(value: Any, forKey key: String) {
        UserDefaults.standard.set(value, forKey: KeyValueStore.prefix + key)
    }
    
    private func value<T>(forKey key: String) -> T? {
        return (UserDefaults.standard.object(forKey: KeyValueStore.prefix + key) as? T)
    }
}

extension KeyValueStore {
    var registration: Registration? {
        get {
            guard
                let deviceId = deviceId,
                let apiToken = apiToken else { return nil }
            
            return Registration(deviceId: deviceId, apiToken: apiToken)
        }
        set {
            if let value = newValue {
                apiToken = value.apiToken
                deviceId = value.deviceId
            }
        }
    }
}

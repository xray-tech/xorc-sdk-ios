//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import XrayKit
import UserNotifications


/**
 The encodable request top most body of an events request
 */
class NetworkModel: Encodable {
    let events: [EventNetworkModel]
    let device: ParametersProvider
    let environment: ParametersProvider
    
    init(events: [EventNetworkModel], environment: ParametersProvider) {
        self.events = events
        self.environment = environment
        self.device = ParametersProvider.device()
    }
}

/// A group key value providers
struct ParametersProvider: Encodable {
    let providers: [ParameterProvider]
    
    func encode(to encoder: Encoder) throws {
        var encoder = encoder.singleValueContainer()
        var parameters =  [String: JSONValue]()
        
        providers.forEach { provider in
            parameters.merge(provider.json) { (current, _) in current }
        }
        try encoder.encode(parameters)
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
        if let properties = event.properties {
            try container.encode(properties, forKey: .properties)
        }
    }
}

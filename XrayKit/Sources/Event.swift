//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

@objc
public final class Event: NSObject {

    enum Status: Int {
        /// The event was created and will be sent
        case queued     = 0
        
        // The event is being sent
        case sending    = 1
        
        // The event was successfully sent
        case success    = 2
        
        // The event was sent but the backend marked is as failed. It should be retried again
        case retry      = 3
        
        // The event was retried too many times and will be discarded
        case error      = 4
    }

    enum Priority: Int {
        // The event will be sent with next scheduled batch
        case normal     = 0

        // The event will be sent immediately
        case important  = 1
    }
    
    /// The scope of the event
    public enum Scope: Int {
        /// The event will not be send to a `Trasnmitter` and will remain only local to the device
        case local
        
        /// The event will be transmitted to the network via a `Transmitter`
        case remote
    }
    
    var sequenceId: Int64
    public let name: String
    public let properties: [String: JSONValue]?
    public let context: [String: JSONValue]?
    let createdAt: Date
    var updatedAt: Date
    var nextRetryAt: Date?
    
    var status: Status
    
    let scope: Scope
    
    
    init(name: String, properties: [String: JSONValue]?, context: [String: JSONValue]?, scope: Scope = .remote, sequenceId: Int64 = 0, createdAt: Date = Date(), updatedAt: Date = Date(), status: Status = .queued) {
        self.sequenceId = sequenceId
        self.name = name
        self.properties = properties
        self.context = context
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.status = status
        self.scope = scope
        
    }
    
    convenience public init(name: String, properties: [String: JSONValue]? = nil, context: [String: JSONValue]? = nil, scope: Scope = .remote) {
        self.init(name: name, properties: properties, context: context, scope: scope, sequenceId: 0)
    }
    
    override public var description: String {
        var props = ""
        if let properties = properties {
            props = properties.description
        }

        return """
        
        sequenceId  : \(sequenceId)
        name        : \(name)
        properties  : \(props)
        createdAt   : \(createdAt)
        updatedAt   : \(updatedAt)
        nextRetryAt : \(nextRetryAt != nil ? nextRetryAt!.description : "-")
        status      : \(status)
        """
    }

}

// todo: this format is xray http specific
extension Event: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case sequenceId = "id"
        case name
        case properties
        case createdAt = "timestamp"
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(sequenceId)", forKey: .sequenceId)
        try container.encode(name, forKey: .name)
        try container.encode(properties, forKey: .properties)
        
        let timestamp = "\(Int(createdAt.timeIntervalSince1970))"
        try container.encode(timestamp, forKey: .createdAt)
    }
}

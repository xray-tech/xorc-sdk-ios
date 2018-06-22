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
        case failed     = 3
        
        // The event was retried too many times and will be discarded
        case error      = 4
    }

    enum Priority: Int {
        // The event will be sent with next scheduled batch
        case normal     = 0

        // The event will be sent immediately
        case important  = 1
    }
    
    var sequenceId: Int64
    let name: String
    let properties: [String: JSONValue]?
    let createdAt: Date
    var updatedAt: Date
    
    var status: Status
    
    
    init(name: String, properties: [String: JSONValue]?, sequenceId: Int64 = 0, createdAt: Date = Date(), updatedAt: Date = Date(), status: Status = .queued) {
        self.sequenceId = sequenceId
        self.name = name
        self.properties = properties
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.status = status
        
    }

    convenience public init(name: String, properties: [String: JSONValue]? = nil) {
        self.init(name: name, properties: properties, sequenceId: 0)
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
        status      : \(status)
        """
    }

}

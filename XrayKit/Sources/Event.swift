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
    
    var sequenceId: Int64
    let name: String
    let properties: [String: Codable]?
    let createdAt: Date
    let updatedAt: Date
    
    var status: Status
    
    
    init(name: String, properties: [String: Codable]? = nil, sequenceId: Int64 = 0, createdAt: Date = Date(), updatedAt: Date = Date(), status: Status = .queued) {
        self.sequenceId = sequenceId
        self.name = name
        self.properties = properties
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.status = status
        
    }

    convenience public init(name: String, properties: [String: Codable]? = nil) {
        self.init(name: name, properties: properties, sequenceId: 0)
    }
}

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
    let properties: [String: Codable]?
    let createdAt: Date
    var updatedAt: Date
    
    var status: Status
    
    
    init(name: String, properties: [String: Codable]?, sequenceId: Int64 = 0, createdAt: Date = Date(), updatedAt: Date = Date(), status: Status = .queued) {
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
    
    convenience init(binds: [String: AnyObject]) throws {
        guard let name = binds[EventTable.columnName] as? String else { throw SQLConnection.SQLError.parseError("Expected a event name") }
        guard let sequenceId = binds[EventTable.columnId] as? NSNumber else { throw SQLConnection.SQLError.parseError("Expected a event id") }
        guard let createdAt = binds[EventTable.columnCreatedAt] as? NSNumber else { throw SQLConnection.SQLError.parseError("Expected a columnCreatedAt") }
        guard let updatedAt = binds[EventTable.columnUpdatedAt] as? NSNumber else { throw SQLConnection.SQLError.parseError("Expected a columnUpdatedAt") }
        
        guard
            let statusNumber = binds[EventTable.columnStatus] as? NSNumber,
            let status = Event.Status(rawValue: statusNumber.intValue)
        
            else { throw SQLConnection.SQLError.parseError("Expected a columnStatus") }
        
        let properties = [String: Codable]()
        
        // todo
//        if
//            let propertiess = binds[EventTable.columnProperties] as? NSString,
//            let data = propertiess.data(using: 0)
//        {
//            let props = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Codable]
//            let decoder = JSONDecoder()
//            decoder.decode([String: Decodable].self, from: data)
//        }
        
        self.init(name: name,
                  properties: properties,
                  sequenceId: sequenceId.int64Value,
                  createdAt: Date(timeIntervalSince1970: createdAt.doubleValue),
                  updatedAt: Date(timeIntervalSince1970: updatedAt.doubleValue),
                  status: status)
        
        
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

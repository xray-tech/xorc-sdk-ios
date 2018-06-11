//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

@objc
public class Event: NSObject {

    var sequenceId: Int64
    let name: String
    let properties: [String: AnyObject]?
    let createdAt: Date
    let updatedAt: Date
    
    @objc
    public init(name: String, properties: [String: AnyObject]? = nil, sequenceId: Int64 = 0, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.sequenceId = sequenceId
        self.name = name
        self.properties = properties
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
    }

    convenience init(name: String, properties: [String: AnyObject]? = nil) {
        self.init(name: name, properties: properties, sequenceId: 0)
    }
}

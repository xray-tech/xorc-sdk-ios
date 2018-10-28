//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

/**
 The `DataPayload` represents the data packet to be delivered to your application when needed. It contains arbitrary data relevant to you
 along with conditions when it will be delivered to your app based on triggers.
 When you hand over a `DataPayload` to the Xray SDK, it will be persisted until triggered or expired.
 */
public struct DataPayload {
    
    public enum Trigger {
        case event(EventTrigger)
        case date(Date)
        case remote
    }
    /// The arbitrary data to be delivered to your app
    public let data: Data
    
    /// A object containing custom information associated with the data.
    public let userInfo: [String: JSONValue]?
    
    public let trigger: Trigger
    
    /// persistence uid
    var entryId: Int64
    
    let expiresAt: Date?
    let createdAt: Date
    var updatedAt: Date

    init(data: Data, trigger: Trigger, userInfo: [String: JSONValue]? = nil, expiresAt: Date? = nil, entryId: Int64 = 0, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.data = data
        self.userInfo = userInfo
        self.expiresAt = expiresAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.entryId = entryId
        self.trigger = trigger
    }
    
    public init(data: Data, trigger: Trigger, userInfo: [String: JSONValue]? = nil, expiresAt: Date? = nil) {
        self.init(data: data, trigger: trigger, userInfo: userInfo, expiresAt: expiresAt, entryId: 0)
    }
}

//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

protocol EventStore {
    
    @discardableResult
    func insert(event: Event) -> Event

    func select(maxNextTryAt: Date, priority: Event.Priority?, batchMaxSize: Int?) -> [Event]
    
    @discardableResult
    func update(event: Event) -> Event
    
    func delete(event: Event)
    
    func delete(events: [Event])
}

protocol DataStore {
    
    @discardableResult
    func insert(payload: DataPayload) -> DataPayload
    
    func select(eventName: String) -> [DataPayload]
}

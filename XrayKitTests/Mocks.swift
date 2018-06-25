//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

@testable import XrayKit

class MockTrasnmitter: EventTransmitter {
    
    var events = [Event]()
    
    func transmit(events: [Event], completion: @escaping (EventResult) -> Void) {
        self.events += events
    }
}

class MemoryEventStore: EventStore {
    
    var events = [Event]()
    
    var sequence: Int64 = 1
    
    func insert(event: Event) -> Event {
        event.sequenceId = sequence
        sequence += 1
        events.append(event)
        return event
    }
    
    func select(maxNextTryAt: Date, priority: Event.Priority?, batchMaxSize: Int?) -> [Event] {
        return events
    }
    
    func update(event: Event) -> Event {
        return event
    }
    
    func delete(event: Event) {
        events = events.filter { $0.sequenceId != event.sequenceId }
    }
    
    func delete(events: [Event]) {
        
        let ids = events.map { $0.sequenceId }
        self.events = events.filter { !ids.contains($0.sequenceId) }
    }
}

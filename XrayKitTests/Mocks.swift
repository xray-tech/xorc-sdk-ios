//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

@testable import XrayKit

class MockTrasnmitter: EventTransmitter {
    
    enum MockBehaviour {
        case succeed
        case retry(nextRetryAt: Date)
        case fail
        case none // dont call the completion at all
    }
    
    let behaviour: MockBehaviour
    
    init(behaviour: MockBehaviour = .none) {
        self.behaviour = behaviour
    }
    
    var events = [Event]()
    
    
    func transmit(events: [Event], completion: @escaping ([EventResult]) -> Void) {
        self.events += events
        
        switch behaviour {
        case .succeed:
            completion(events.map { .success(event: $0) })
        case .retry(let nextRetryAt):
            completion(events.map { .retry(event: $0, nextRetryAt: nextRetryAt) })
        case .fail:
            completion(events.map { .failure(event: $0) })
        case .none: break
        }
    }
}

class MemoryEventStore: EventStore {
    
    var events = [Event]()
    var deleted = [Event]()
    var updated = [Event]()
    
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
        updated.append(event)
        return event
    }
    
    func delete(event: Event) {
        deleted.append(event)
        events = events.filter { $0.sequenceId != event.sequenceId }
    }
    
    func delete(events: [Event]) {
        deleted += events
        let ids = events.map { $0.sequenceId }
        self.events = events.filter { !ids.contains($0.sequenceId) }
    }
}

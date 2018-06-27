//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

/**
 Represents the result of transmitting events.
 */
public enum EventResult {
    
    /// When the event was transmitted correctly.
    case success(event: Event)
    
    /// When the events should be retried.
    case retry(event: Event, nextRetryAt: Date)
    
    /// When the event failed and should be discarded
    case failure(event: Event)
}

/**
 The `EventTransmitter` defines an interface for transmitting events. The implementations responsible for serializing the `Event`s and
 transmitting them via their own protocol.
 */
public protocol EventTransmitter {
    
    /**
     This method is called internally by the Xray SDK when the event is ready to be transmitted.
     - parameter events: The `Event`s to be transmitted.
     - parameter completion: The `EventResult` completion closure telling the SDK whether the events were transmitted correctly or not.
     - warning: Do not call this method. It is meant to be called by the SDK at the right time.
    */
    func transmit(events: [Event], completion: @escaping ([EventResult]) -> Void)
}

class EventController {
    
    enum SendingStatus {
        case sending
        case paused
    }
    
    public var transmitter: EventTransmitter?

    private var eventStore: EventStore

    init(eventStore: EventStore, transmitter: EventTransmitter? = nil) {
        self.eventStore = eventStore
        self.transmitter = transmitter
    }
    
    /// Adds the event to the sending queue
    public func log(event: Event, flush: Bool = true) {
        var event = event
        print("Logging event \(event)")
        
        // run event through the rule engine
        
        if event.scope == .local {
            return
        }

        event = eventStore.insert(event: event)

        if flush {
            self.flush()
        }
    }
    
    /// flushes all persisted events and transmits them
    public func flush() {
        guard let transmitter = transmitter else {
            // nothing else to do. We do not transmit at all
            return
        }
        let events = prepareSendableEvents()
        
        transmitter.transmit(events: events) { results in
            
            for result in results {
                switch result {
                case .success(let event):
                    self.eventStore.delete(event: event)
                case .retry(let event, let nextRetryAt):
                    event.nextRetryAt = nextRetryAt
                    event.status = .retry
                    self.eventStore.update(event: event)
                case .failure(let event):
                    self.eventStore.delete(event: event)
                }
            }
        }
    }

    /// Selects the sendable events and updates their status to `sending` in the store
    private func prepareSendableEvents() -> [Event] {
        let events = eventStore.select(maxNextTryAt: Date(), priority: nil, batchMaxSize: nil)
        for event in events {
            event.status = .sending
            eventStore.update(event: event)
        }
        return events
    }
}

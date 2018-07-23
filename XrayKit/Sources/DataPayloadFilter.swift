//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

/**
 A `DataPayloadFilter` takes in a list of `DataPayload`s and an `Event` and filters out the payloads that match and those that don't.
 The payloads that match are candidates to be executed.
 The payloads that don't can be either discarded completely or kept.
*/
protocol DataPayloadFilter {
  
    /**
     Applies the filter to a list of `DataPayload` for an occurred event.
     
     - parameter payloads: The list of payloads that already match the event name
     - parameter event: The event that was used to query by name all the payloads
     
     - warning: It is assumed that all payloads do have an `EventTrigger` with the only name matching the passed event.
     */
    static func filter(payloads: [DataPayload], withEvent event: Event) -> FilterResult
}


struct FilterResult {
    let matched: [DataPayload]
    let mismatched: [Mismatch]
}

/**
 Represents a payload that did not match a filter and what should be done with it
 */
struct Mismatch {
    
    /// How to handle the payload.
    enum Handle {
        case keep       /// Keep the payload for the next time
        case delete     /// Delete the payload
    }
    
    let payload: DataPayload
    let handle: Handle
}

struct EventPropertyFilter: DataPayloadFilter {
    
    static func filter(payloads: [DataPayload], withEvent event: Event) -> FilterResult {
        var mismatched  = [Mismatch]()
        var matched = [DataPayload]()
        
        
        for payload in payloads {
            switch payload.trigger {
            case .event(let eventTrigger):
                // safety check for event name even though we expect all data payload to already have the correct event *name*
                if event.name != eventTrigger.name {
                    mismatched.append(Mismatch(payload: payload, handle: .keep))
                    continue
                }
                
                // no property filters, and the event name matches
                guard let filters = eventTrigger.filters else {
                    matched.append(payload)
                    continue
                }
                
                // run the event through the properties predicate
                do {
                    let predicate = try NSPredicate.makePredicate(filters: filters)
                    let proxy = PredicateProxy(event: event)
                    let matches = predicate.evaluate(with: proxy)
                    print("Predicate \(predicate) \(matches ? "matches" : "does not match") event \(event)")
                    if matches {
                        matched.append(payload)
                    } else {
                        mismatched.append(Mismatch(payload: payload, handle: .keep))
                    }
                } catch {
                    // something went wrong when building the filter
                    // todo more delete reasons?
                    print("Could not create a predicate from event trigger. Discarding payload", error)
                    mismatched.append(Mismatch(payload: payload, handle: .delete))
                }
            case .date:
                // not a event base trigger, keep it as it is
                mismatched.append(Mismatch(payload: payload, handle: .keep))
            }
        }
        
        return FilterResult(matched: matched, mismatched: mismatched)
    }
}

struct ExpiredDataPayloadFilter: DataPayloadFilter {

    static func filter(payloads: [DataPayload], withEvent event: Event) -> FilterResult {
        
        var mismatched  = [Mismatch]()
        var matched = [DataPayload]()
        
        let now = Date()
        for payload in payloads {
            if let expiredAt = payload.expiresAt, expiredAt < now {
                mismatched.append(Mismatch(payload: payload, handle: .delete))
            } else {
                matched.append(payload)
            }
        }
        return FilterResult(matched: matched, mismatched: mismatched)
    }
}

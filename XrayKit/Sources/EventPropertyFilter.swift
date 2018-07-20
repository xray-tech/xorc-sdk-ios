//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

struct EventPropertyFilter: DataPayloadFilter {

    static func filter(payloads: [DataPayload], withEvent event: Event) -> FilterResult {
        var mismatched  = [Mismatch]()
        var matched = [DataPayload]()


        for payload in payloads {
            switch (payload.trigger) {
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

                break
            case .date(_):
                // not a event base trigger, keep it as it is
                mismatched.append(Mismatch(payload: payload, handle: .keep))
                break
            }
        }
        // safety


        return FilterResult(matched: matched, mismatched: mismatched)
    }
}

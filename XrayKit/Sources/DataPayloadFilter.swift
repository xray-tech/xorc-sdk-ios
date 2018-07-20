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

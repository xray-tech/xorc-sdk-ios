//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

/**
    This object is a proxy object passed to the evaluation of predicates in order to make evaluation by key path such as 'event.properties.item_name' possible
 */
class PredicateProxy: NSObject {

    @objc
    let event: KVEvent

    init(event: Event) {
        self.event = KVEvent(event: event)
    }
}

/// Event that key be used in a key value coding for properties
class KVEvent: NSObject {
    @objc
    let properties: [String: Any]

    init(event: Event) {
        var properties = [String: Any]()
        if let props = event.properties {
            for (key, value) in props {
                properties[key] = value.anyValue
            }
        }

        self.properties = properties
    }
}

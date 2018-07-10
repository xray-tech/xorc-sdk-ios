//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

class DataController {
    
    let store: DataStore
    
    init(store: DataStore) {
        self.store = store
    }
    
    func schedule(payload: DataPayload) {
        print("Scheduling data to trigger at \(payload.trigger)")
        store.insert(payload: payload)
    }
    
    /**
     Method to be called when a event occured. The `DataController` processes any stored `DataPayloads` for the tracked events
     and calls the delegate if sone are found
     
     - parameter event: The event that occured
    */
    func trackEvent(event: Event) {
        // todo on data queue async
        // todo find and filter DataPayloads  for that event name
        print("Checking data for event \(event.name)")
    }
}

//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

class DataController {
    
    let store: DataStore
    
    private let queue = DispatchQueue(label: "io.xorc.data")
    
    init(store: DataStore) {
        self.store = store
    }
    
    func start() {
        purgeExpired()
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
        queue.async {
            
            let payloads = self.store.select(forTriggerEventName: event.name)
            print("Found \(payloads.count) payloads for event '\(event.name)'")
            
            // todo use payload selector to filters matching payloads
            // todo delete payloads to be discarded
            // todo call delegates for discarded entries
            // todo if the payload has a delay, change the trigger to executeAt and hand it over to a scheduler
            // todo if no delay, pass it to a delegate
            
            self.store.delete(payloads: payloads)
        }
    }
    
    // MARK: - Private
    
    /// Finds and deletes all expired data payloads
    private func purgeExpired() {
        
    }
}

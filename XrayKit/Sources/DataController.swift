//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

class DataController {
    
    let store: DataStore
    
    private let queue = DispatchQueue(label: "io.xorc.data")
    
    public var onTrigger: (([DataPayload]) -> Void)?
    
    private let filters: [DataPayloadFilter.Type] = [ExpiredDataPayloadFilter.self]
    
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
        print("Checking data for event \(event.name)")
        queue.async {
            
            let payloads = self.store.select(forTriggerEventName: event.name)
            print("Found \(payloads.count) payloads for event '\(event.name)'")
            
            
            var mismatched = [Mismatch]()
            var matched = payloads
            
            // use payload filters to filter matching payloads
            for filter in self.filters {
                let result = filter.filter(payloads: matched, withEvent: event)
                
                matched = result.matched
                mismatched.append(contentsOf: result.mismatched)
            }
            
            // delete payloads that
            // - did not match and are marked to be deleted
            // - did match (todo if there is a reenter flag, keep them)
            var payloadsToDelete = mismatched
                .filter({ $0.handle == .delete })
                .map { $0.payload }
            
            payloadsToDelete.append(contentsOf: matched)
            // delete payloads that were triggered
            self.store.delete(payloads: payloads)
            
            // todo call delegates for discarded entries
            // todo if the payload has a delay, change the trigger to executeAt and hand it over to a scheduler
            // todo if no delay, pass it to a delegate
            self.onTrigger?(matched)
                
            
        }
    }
    
    // MARK: - Private
    
    /// Finds and deletes all expired data payloads
    private func purgeExpired() {
        
    }
}

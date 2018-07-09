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
}

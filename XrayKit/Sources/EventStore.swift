//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

protocol EventStore {
    
    func insert(event: Event) -> Event

    func select(maxNextTryAt: Date, priority: Event.Priority?, batchMaxSize: Int?) -> [Event]
}

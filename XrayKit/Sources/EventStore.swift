//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

protocol EventStore {
    
    func insert(element: Event) -> Event

    func select(priority: Event.Priority, nextTryAt: Date, batchMaxSize: Int)
}

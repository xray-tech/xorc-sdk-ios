//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation


protocol Table {
 
    var name: String { get }
    var createRequest: SQLRequest { get }
}

struct EventTable: Table {
    
    var tableName = "events"
    var id = "id"
    var name = "name"
    
    var createRequest: SQLRequest {
        return SQLRequest(sql:
            "CREATE TABLE IF NOT EXISTS \(tableName)(\(id) INTEGER PRIMARY KEY AUTOINCREMENT, \(name) TEXT NOT NULL)"
        )
    }
    
}

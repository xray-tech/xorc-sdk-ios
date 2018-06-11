//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation


protocol Table {
 
    var tableName: String { get }
    var createRequest: SQLRequest { get }
}

struct EventTable: Table {
    
    var tableName = "events"
    var columnId = "id"
    var columnName = "name"
    
    var createRequest: SQLRequest {

        return SQLRequest(sql: "CREATE TABLE IF NOT EXISTS \(tableName)(\(columnId) INTEGER PRIMARY KEY AUTOINCREMENT, \(columnName) TEXT NOT NULL)"
        )
    }
    
}

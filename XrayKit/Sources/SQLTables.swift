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
    
    var tableName           = "events"
    var columnId            = "id"
    var columnName          = "name"
    var columndCreatedAt    = "createdAt"
    var columndUpdatedAt    = "updatedAt"
    var columndStatus       = "status"
    var columndPayload      = "payload"
    
    var createRequest: SQLRequest {

        return SQLRequest(sql: """
            CREATE TABLE IF NOT EXISTS \(tableName)
            (
                \(columnId) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(columnName) TEXT NOT NULL,
                \(columndCreatedAt) INTEGER DEFAULT 0,
                \(columndUpdatedAt) INTEGER DEFAULT 0,
                \(columndStatus) INTEGER DEFAULT 0,
                \(columndPayload) TEXT NOT NULL
            )
            """
        )
    }
    
}

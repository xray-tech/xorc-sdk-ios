//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation


struct DataTable: Table {
    
    static let tableName          = "data"
    static let columnId           = "id"
    static let columnEventName    = "eventName"
    static let columnEventFilter  = "eventFilter"
    static let columnCreatedAt    = "createdAt"
    static let columnUpdatedAt    = "updatedAt"
    static let columnExpiresAt    = "expiresAt"
    static let columnExecuteAt    = "executeAt"
    static let columnData         = "data"
    static let columnContext      = "context"
    
    
    static let createRequest = SQLRequest(sql: """
        CREATE TABLE IF NOT EXISTS \(tableName)
        (
        \(columnId) INTEGER PRIMARY KEY AUTOINCREMENT,
        \(columnEventName) TEXT,
        \(columnEventFilter) TEXT,
        \(columnCreatedAt) INTEGER DEFAULT 0,
        \(columnUpdatedAt) INTEGER DEFAULT 0,
        \(columnExecuteAt) INTEGER DEFAULT 0,
        \(columnExpiresAt) INTEGER DEFAULT 0,
        \(columnData) BLOB
        \(columnContext) TEXT
        )
        """
    )
}


extension DataPayload: Insertable {
    var sequenceId: Int64 {
        get {
            return entryId
        }
        set {
            entryId = sequenceId
        }
    }
    
    
    static let tableName = DataTable.tableName
    static let  identField = DataTable.columnId
    
    var binds: [String: AnyObject] {
        var binds = [String: AnyObject]()
        
        let table = DataTable.self
        binds[table.columnCreatedAt] = createdAt.toSql()
        binds[table.columnUpdatedAt] = updatedAt.toSql()
        binds[table.columnData] = data as NSData
        
        switch trigger {
        case .date(let executeAt):
            binds[table.columnExecuteAt] = executeAt.toSql()
        case .event(let eventTrigger):
            binds[table.columnEventName] = eventTrigger.name as NSString
            
            if
                let data = try? JSONSerialization.data(withJSONObject: eventTrigger.filters, options: []),
                let string = String(data: data, encoding: .utf8) {
                binds[table.columnEventFilter] = string as NSString
            }
        }
        

        if entryId != 0 {
            binds[table.columnId] = entryId as NSNumber
        }
        
        return binds
    }
}

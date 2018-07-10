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
                let filters = eventTrigger.filters,
                let data = try? JSONSerialization.data(withJSONObject: filters, options: []),
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

extension DataPayload: Deserializable {
    
    static func deserialize(_ element: [String: AnyObject]) throws -> DataPayload {
        return try DataPayload(binds: element)
        
    }
    
    init(binds: [String: AnyObject]) throws {
        let table = DataTable.self
        guard let data = binds[table.columnData] as? NSData else {
            throw SQLConnection.SQLError.parseError("Expected data")
        }
        
        guard let entryId = binds[table.columnId] as? NSNumber else {
            throw SQLConnection.SQLError.parseError("Expected \(table.columnId)")
        }
        guard let createdAt = binds[table.columnCreatedAt] as? NSNumber else {
            throw SQLConnection.SQLError.parseError("Expected a \(table.columnCreatedAt)")
        }
        guard let updatedAt = binds[table.columnUpdatedAt] as? NSNumber else {
            throw SQLConnection.SQLError.parseError("Expected a \(table.columnUpdatedAt)")
        }
        
        var trigg: DataPayload.Trigger?
        
        
        // parse event based trigger
        if let eventName = binds[table.columnEventName] as? String {
            // event with filters
            if let jsonFilters = binds[table.columnEventFilter] as? String {
                trigg = .event(try EventTrigger(name: eventName, jsonFilters: jsonFilters))
            } else {
                // event without filters
                trigg = .event(EventTrigger(name: eventName))
            }
        }
        
        if let executeAt = binds[table.columnExecuteAt] as? NSNumber, executeAt.doubleValue > 0 {
            trigg = .date(Date(timeIntervalSince1970: executeAt.doubleValue))
        }
        
        var expieresAt: Date?
        if let expiresAtTimeInterval = binds[table.columnExpiresAt] as? NSNumber {
            expieresAt = Date(timeIntervalSince1970: expiresAtTimeInterval.doubleValue)
        }
        
        // we need at least one valid trigger
        guard let trigger = trigg else {
           throw SQLConnection.SQLError.parseError("No data persisted data trigger")
        }


        // todo other prope
        // todo expires at
        self.init(data: data as Data,
                  trigger: trigger,
                  userInfo: nil,
                  expiresAt: expieresAt,
                  entryId: entryId.int64Value,
                  createdAt: Date(timeIntervalSince1970: createdAt.doubleValue),
                  updatedAt: Date(timeIntervalSince1970: updatedAt.doubleValue))
    }
}

extension DataPayload: Deletable {
    
}

extension DataPayload {
    
    // MARK: - SQL
    
    // Returns the WHERE SQL for events that can be sent
    static func whereEventName(eventName: String) -> String {
        return "\(DataTable.columnEventName) = '\(eventName)'"
    }
}

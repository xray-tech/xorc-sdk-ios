//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

struct EventTable: Table {

    static let tableName          = "events"
    static let columnId           = "id"
    static let columnName         = "name"
    static let columnCreatedAt    = "createdAt"
    static let columnUpdatedAt    = "updatedAt"
    static let columnNextTryAt    = "nextTryAt"
    static let columnPriority     = "priority"
    static let columnStatus       = "status"
    static let columnProperties   = "properties"


    static let createRequest = SQLRequest(sql: """
            CREATE TABLE IF NOT EXISTS \(tableName)
            (
                \(columnId) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(columnName) TEXT NOT NULL,
                \(columnCreatedAt) INTEGER DEFAULT 0,
                \(columnUpdatedAt) INTEGER DEFAULT 0,
                \(columnNextTryAt) INTEGER DEFAULT 0,
                \(columnPriority) INTEGER DEFAULT 0,
                \(columnStatus) INTEGER DEFAULT 0,
                \(columnProperties) TEXT
            )
            """
    )
}

extension Event: Insertable {

    static let tableName = EventTable.tableName
    static let  identField = EventTable.columnId

    var binds: [String: AnyObject] {
        var binds = [String: AnyObject]()
        
        let table = EventTable.self
        binds[table.columnName] = name as NSString
        binds[table.columnCreatedAt] = createdAt.toSql()
        binds[table.columnUpdatedAt] = updatedAt.toSql()
        binds[table.columnStatus] = status.rawValue as NSNumber
        
        if sequenceId != 0 {
            binds[table.columnId] = sequenceId as NSNumber
        }
        
        if
            let properties = properties,
            let data = try? JSONSerialization.data(withJSONObject: properties, options: []),
            let json = String(data: data, encoding: .utf8)
        {
            binds[table.columnProperties] = json as NSString
        }

        return binds
    }
}

extension Event: Updatable {

}

extension Event: Deserializable {

    static func deserialize(_ element: [String: AnyObject]) throws -> Event {
        return try Event(binds: element)
    }
}

// MARK: - SQL

extension Event {
    // MARK: - SQL

    // Returns the WHERE SQL for events that can be sent
    static func whereSendableSQL(maxNextTryAt: Date, priority: Event.Priority? = nil) -> String {
        var sql =  "(\(EventTable.columnStatus) = \(Event.Status.queued.rawValue) OR \(EventTable.columnStatus) = \(Event.Status.queued.rawValue)) AND \(EventTable.columnNextTryAt) <= \(maxNextTryAt.timeIntervalSince1970)"

        if let priority = priority {
            sql += " AND \(EventTable.columnPriority) = \(priority.rawValue)"
        }
        return sql
    }
}

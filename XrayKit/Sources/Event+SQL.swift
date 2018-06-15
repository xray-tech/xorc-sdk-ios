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
    static let columnStatus       = "status"
    static let columnProperties   = "properties"

    static let createRequest = SQLRequest(sql: """
            CREATE TABLE IF NOT EXISTS \(tableName)
            (
                \(columnId) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(columnName) TEXT NOT NULL,
                \(columnCreatedAt) INTEGER DEFAULT 0,
                \(columnUpdatedAt) INTEGER DEFAULT 0,
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
        
        guard let name = element[EventTable.columnName] as? String else { throw SQLConnection.SQLError.executeError("") }
        
        let event = Event(name: name)
        return event
    }
}

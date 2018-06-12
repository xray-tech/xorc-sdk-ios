//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation


protocol Table {

    static var tableName: String { get }
    static var createRequest: SQLRequest { get }
}

protocol Insertable {

    static var tableName: String { get }

    static var identField: String { get }

    var sequenceId: Int64 { get set }
    var binds: [String: AnyObject] { get }
    
    var insertRequest: SQLRequest { get }
}

extension Insertable {
    
    var insertRequest: SQLRequest {
        return SQLRequest(insertInto: type(of: self).tableName, binds: binds)
    }
}

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

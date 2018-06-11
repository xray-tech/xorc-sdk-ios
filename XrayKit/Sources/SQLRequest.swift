//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

struct SQLRequest {
    
    enum Order: String {
        case asc = "ASC"
        case desc = "DESC"
    }
    
    enum RequestType {
        case plain
        case insert
        case select
        case count
    }
    
    
    let sql: String
    let type: RequestType
    let binds: [String: AnyObject]?
    
    init(sql: String, type: RequestType, binds: [String: AnyObject]? = nil) {
        self.type = type
        self.sql = sql
        self.binds = binds
    }
    
    init(sql: String) {
        self.init(sql: sql, type: .plain)
    }
    
    init(insertInto table: String, binds: [String: AnyObject]) {
        self.init(sql: String.sqlInsert(tableName: table, fields: Array(binds.keys)), type: .insert, binds: binds)
    }

    
    func build() -> String {
        return sql
    }
}

struct SQLResult {
    let insertId: Int64?
    let rowsChanged: Int32
    
    
    init(insertId: Int64? = nil, rowsChanged: Int32 = 0) {
        self.insertId = insertId
        self.rowsChanged = rowsChanged
    }
}

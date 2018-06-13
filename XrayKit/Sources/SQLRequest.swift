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

    init(selectFrom table: String, fields: [String]? = nil, whereSQL: String? = nil, order: [(String, SQLRequest.Order)]? = nil) {
        let sql = String.sqlSelect(tableName: table, fields: fields, whereSQL: whereSQL, order: order)
        self.init(sql: sql, type: .select)
    }
    
    func build() -> String {
        return sql
    }
}

struct SQLResult {
    let insertId: Int64?
    let rowsChanged: Int32
    let resultSet: [[String: AnyObject]]?
    
    init(insertId: Int64? = nil, rowsChanged: Int32 = 0, resultSet: [[String: AnyObject]]? = nil) {
        self.insertId = insertId
        self.rowsChanged = rowsChanged
        self.resultSet = resultSet
    }
    init (resultSet: [[String: AnyObject]]) {
        self.init(insertId: nil, rowsChanged: 0, resultSet: resultSet)
    }
}

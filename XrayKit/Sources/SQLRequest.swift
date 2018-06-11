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
    
    init(sql: String, type: RequestType) {
        self.type = type
        self.sql = sql
    }
    
    init(sql: String) {
        self.init(sql: sql, type: .plain)
    }
    
//    init(insertInto table: String, binds: [String: AnyObject]) {
//        self.init(sql: sql, type: .insert)
//    }
    func build() -> String {
        return sql
    }
}

struct SQLResult {
    let insertId: Int64
    
    init() {
        self.insertId = 0
    }
}

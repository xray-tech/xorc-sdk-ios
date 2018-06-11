//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

extension String {
    
    static func sqlInsert(tableName: String, fields: [String]) -> String {
        // INSERT INTO events (status, updatedAt) VALUES (:status, :updatedAt)
        let columns = fields.joined(separator: ", ")
        let values = fields.map({ ":\($0)" }).joined(separator: ", ")
        return "INSERT INTO \(tableName) (\(columns)) VALUES (\(values))"
    }
    
    static func sqlSelect(tableName: String, fields: [String]? = nil, whereSQL: String? = nil, order: [(String, SQLRequest.Order)]? = nil) -> String {
        var sql = ""
        var fieldsSql = "*"
        
        if let fields = fields {
            fieldsSql = fields.joined(separator: ", ")
        }
        sql = "SELECT \(fieldsSql) FROM \(tableName)"
        
        if let whereSQL = whereSQL {
            sql += " WHERE \(whereSQL)"
        }
        if let order = order, order.count > 0 {
            let values = order.map() { $0 + " " + $1.rawValue }
            sql += " ORDER BY \(values.joined(separator: ", "))"
        }
        

        return sql
    }
}

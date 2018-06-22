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
        
        if let fields = fields, !fields.isEmpty {
            fieldsSql = fields.joined(separator: ", ")
        }
        sql = "SELECT \(fieldsSql) FROM \(tableName)"
        
        if let whereSQL = whereSQL {
            sql += " WHERE \(whereSQL)"
        }
        if let order = order, !order.isEmpty {
            let values = order.map { $0 + " " + $1.rawValue }
            sql += " ORDER BY \(values.joined(separator: ", "))"
        }
        return sql
    }

    static func sqlUpdate(tableName: String, fields: [String], whereSQL: String = "1=1") -> String {
        // all fields to myfield=:myfield
        let fieldsPairs = fields.map { "\($0)=:\($0)" }.joined(separator: ", ")

        //let fieldsSQL = fields.joined(separator: ",: ")
        let sql = "UPDATE \(tableName) SET \(fieldsPairs) WHERE \(whereSQL)"
        return sql
    }
    
    static func sqlDelete(tableName: String, whereSQL: String = "1=1") -> String {
        let sql = "DELETE FROM \(tableName) WHERE \(whereSQL)"
        return sql
    }
}

//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

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

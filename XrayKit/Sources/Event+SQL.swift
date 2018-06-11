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
        binds[EventTable.columnName] = name as NSString
        binds[EventTable.columnCreatedAt] = createdAt.toSql()
        binds[EventTable.columnUpdatedAt] = updatedAt.toSql()

        return binds
    }

}

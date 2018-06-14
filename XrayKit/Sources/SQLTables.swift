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


protocol Deserializable {

    /// Method for deserializing elements from SQL
    static func deserialize(_ element: [String: AnyObject]) throws -> Self
}

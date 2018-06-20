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

protocol Updatable {
    static var tableName: String { get }
    static var identField: String { get }
    var sequenceId: Int64 { get set }
    var updatedAt: Date { get set }
    var binds: [String: AnyObject] { get }
}

extension Updatable {

    mutating func updateRequest() -> SQLRequest {
        updatedAt = Date()
        return SQLRequest(updateTable: type(of: self).tableName, binds: binds, whereSQL: "\(type(of: self).identField)=\(sequenceId)")
    }
}


protocol Deletable {
    static var tableName: String { get }
    static var identField: String { get }
    var sequenceId: Int64 { get set }
}

extension Deletable {
    
    func deleteRequest() -> SQLRequest {
        return SQLRequest(deleteFromTable: type(of: self).tableName, whereSQL: "\(type(of: self).identField)=\(sequenceId)")
    }
}

extension Array where Element: Deletable {
    func deleteRequest() -> SQLRequest {
        let wheres = self.map { "\(type(of: $0).identField)=\($0.sequenceId)" }.joined(separator: " OR ")
        return SQLRequest(deleteFromTable: Element.tableName, whereSQL: wheres)
    }
}

protocol Deserializable {

    /// Method for deserializing elements from SQL
    static func deserialize(_ element: [String: AnyObject]) throws -> Self
}

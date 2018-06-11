//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import SQLite3

let SQLITETRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

protocol Connection {
    func execute(request: SQLRequest) throws  -> SQLResult
}

class SQLConnection: Connection {
    
    enum SQLError: Error {
        case openError(String)
        case executeError(String)
        case closeError(String)
    }
    
    let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func execute(request: SQLRequest) throws  -> SQLResult {
        let database = try open()
        print("SQL: \(request.build())")
        
        var statement: OpaquePointer?
        var ret = sqlite3_prepare_v2(database, (request.sql as NSString).utf8String, -1, &statement, nil)
        if ret != SQLITE_OK {
            let message = "sqlite3_prepare_v2 failed: \(String(cString: sqlite3_errstr(ret)))"
            throw SQLError.executeError(message)
        }
        

        if let binds = request.binds {
            for (key, value) in binds {
                let index =  sqlite3_bind_parameter_index(statement, (":\(key)" as NSString).utf8String)
                bind(object: value, toStatement: statement, atParamIndex: index)
            }
        }
        
        
        repeat {
            ret = sqlite3_step(statement)
        } while ret == SQLITE_ROW
        
        if ret != SQLITE_DONE {
            let message = "sqlite3_step failed: \(String(cString: sqlite3_errstr(ret))). \(String(cString: sqlite3_errmsg(database)))"
            throw SQLError.executeError(message)
        }
        
        
        let rowsChanged = sqlite3_changes(database)
        
        var result = SQLResult(rowsChanged: rowsChanged)
        if request.type == .insert {
            let resultId = sqlite3_last_insert_rowid(database)
            result = SQLResult(insertId: resultId, rowsChanged: rowsChanged)
        }
        
        sqlite3_finalize(statement)
        
        try close(database)
        
        return result
    }
    
    // MARK: - Private
    
    private func open() throws -> OpaquePointer? {
        var database: OpaquePointer?
        let ret = sqlite3_open(path, &database)
        if ret == SQLITE_OK {
            print("Successfully opened connection to database at \(path)")
        } else {
            let message = "sqlite3_open failed: \(String(cString: sqlite3_errstr(ret)))"
            throw SQLError.openError(message)
        }
        return database
    }
    
    private func close(_ database: OpaquePointer?) throws {
        let ret = sqlite3_close(database)
        if ret != SQLITE_OK {
            let message = "sqlite3_close failed: \(String(cString: sqlite3_errstr(ret)))"
            throw SQLError.closeError(message)
        }
    }
    
    
    private func bind(object: AnyObject, toStatement statement: OpaquePointer?, atParamIndex index: Int32) {
        switch object {
        case let number as NSNumber:
            if CFNumberIsFloatType(number) {
                sqlite3_bind_double(statement, index, number.doubleValue)
            } else {
                sqlite3_bind_int64(statement, index, number.int64Value)
            }
            
        case let string as NSString:
            sqlite3_bind_text(statement, index, string.utf8String, -1, SQLITETRANSIENT)
            
        case let data as NSData:
            sqlite3_bind_blob(statement, index, data.bytes, Int32(data.length), SQLITETRANSIENT)
            
        default:
            sqlite3_bind_null(statement, index)
            
        }
    }
}

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
            let message = "sqlite3_prepare_v2 failed: \(String(cString: sqlite3_errstr(ret))). \(String(cString: sqlite3_errmsg(database)))"
            throw SQLError.executeError(message)
        }
        
        // If INSERT, bind the values
        if let binds = request.binds {
            for (key, value) in binds {
                let index =  sqlite3_bind_parameter_index(statement, (":\(key)" as NSString).utf8String)
                bind(object: value, toStatement: statement, atParamIndex: index)
            }
        }
        
        var resultSet = [[String: AnyObject]]()
        repeat {
            ret = sqlite3_step(statement)
            if ret == SQLITE_ROW {
                // if count
                // result.count = sqlite3_column_int(statement, 0);
                // else
                let rowObject = row(fromStatement: statement)
                resultSet.append(rowObject)
                
            }
            
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
        
        if request.type == .select && !resultSet.isEmpty {
            result = SQLResult(resultSet: resultSet)
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
    
    /**
     Extracts the SQL row into a dictionary with columns as keys.
     Should be called after a sqlite3_step that returns SQLITE_ROW
    */
    private func row(fromStatement statement: OpaquePointer?) -> [String: AnyObject] {
        var row = [String: AnyObject]()
        let columnCount = sqlite3_data_count(statement)
        for columnIndex in 0..<columnCount {
            let columName = String(cString: sqlite3_column_name(statement, columnIndex))
            if let value = object(from: statement, atColumnIndex: columnIndex) {
                row[columName] = value
            }
        }
        return row
    }
    
    /// Extracts the object from a result statement at the given column index
    private func object(from statement: OpaquePointer?, atColumnIndex columnIndex: Int32) -> AnyObject? {
        let columnType = sqlite3_column_type(statement, columnIndex)
        
        var value: AnyObject?
        switch columnType {
        case SQLITE_INTEGER:
            value = sqlite3_column_int64(statement, columnIndex) as NSNumber
        case SQLITE_FLOAT:
            value = sqlite3_column_double(statement, columnIndex) as NSNumber
        case SQLITE_TEXT:
            if let cString = sqlite3_column_text(statement, columnIndex) {
                value = String(cString: cString) as NSString
            }
            
        case SQLITE_BLOB:
            let bytes = sqlite3_column_blob(statement, columnIndex)
            let length = sqlite3_column_bytes(statement, columnIndex)
            value = NSData(bytes: bytes, length: Int(length))
        default:
            break
        }
        return value
    }
}

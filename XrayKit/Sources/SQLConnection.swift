//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import SQLite3

class SQLConnection {
    
    enum SQLError: Error {
        case openError(String)
        case executeError(String)
        case closeError(String)
    }
    
    let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func execute(request: SQLRequest) throws -> SQLResult {
        let db = try open()
        print("SQL: \(request.build())")
        
        var statement: OpaquePointer?
        var ret = sqlite3_prepare_v2(db, (request.sql as NSString).utf8String, -1, &statement, nil)
        if ret != SQLITE_OK {
            let message = "sqlite3_prepare_v2 failed: \(String(cString: sqlite3_errstr(ret)))"
            throw SQLError.executeError(message)
        }
        
        // todo if binds present, bind objects
        repeat {
            ret = sqlite3_step(statement)
        } while ret == SQLITE_ROW
        
        sqlite3_finalize(statement)
        
        try close(db)
        
        return SQLResult()
    }
    
    // MARK: - Private
    
    private func open() throws -> OpaquePointer?  {
        var db: OpaquePointer?
        let ret = sqlite3_open(path, &db)
        if ret == SQLITE_OK {
            print("Successfully opened connection to database at \(path)")
        } else {
            let message = "sqlite3_open failed: \(String(cString: sqlite3_errstr(ret)))"
            throw SQLError.openError(message)
        }
        return db
    }
    
    private func close(_ db: OpaquePointer?) throws {
        let ret = sqlite3_close(db)
        if ret != SQLITE_OK {
            let message = "sqlite3_close failed: \(String(cString: sqlite3_errstr(ret)))"
            throw SQLError.closeError(message)
        }
    }
}

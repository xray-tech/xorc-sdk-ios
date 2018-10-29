//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import Quick
import Nimble
@testable import XrayKit

class MockConnection: Connection {
    let result: SQLResult
    var request: SQLRequest?
    
    init(result: SQLResult = SQLResult()) {
        self.result = result
    }
    
    func execute(request: SQLRequest) throws -> SQLResult {
        self.request = request
        return result
    }
}

struct TestEntity: Insertable, Deletable {
    
    static var tableName: String = "test_table"
    
    static var identField: String = "test_pkey"
    
    var sequenceId: Int64
    var binds: [String: AnyObject]
}
class SQLDatabaseControllerSpecs: QuickSpec {
    
    let path = "/tmp/xray.sqlite"
    
    override func spec() {
        
        var sut: SQLDatabaseController!
        
        describe("SQLDatabaseController") {
            
            var connection: MockConnection!
            var entry = TestEntity(sequenceId: 0, binds: ["key1": "value1" as NSString])
            
            describe("when creating entities") {
                
                beforeEach {
                    connection = MockConnection(result: SQLResult(insertId: 123))
                    sut = SQLDatabaseController(connection: connection, tables: [])
                    entry = sut.insert(entry: entry)
                }
                
                it("assigns the sequence id") {
                    expect(entry.sequenceId).to(equal(connection.result.insertId))
                }
                
                it("'s request has correct binds") {
                    expect(connection.request?.binds?["key1"] as? NSString).to(equal("value1"))
                }
                
                it("'s request has an insert type") {
                    expect(connection.request?.type).to(equal(SQLRequest.RequestType.insert))
                }
            }
            
            describe("when deleting") {
                
                context("a signle entity") {
                    beforeEach {
                        connection = MockConnection(result: SQLResult())
                        sut = SQLDatabaseController(connection: connection, tables: [])
                        sut.delete(entry: entry)
                    }
                    it("calls the connection with correct where") {
                        expect(connection.request?.sql).to(equal("DELETE FROM \(TestEntity.tableName) WHERE \(TestEntity.identField)=\(entry.sequenceId)"))
                    }
                }
                
                context("multiple entries") {
                    let entry2 = TestEntity(sequenceId: 1, binds: ["key1": "value1" as NSString])
                    beforeEach {
                        connection = MockConnection(result: SQLResult())
                        sut = SQLDatabaseController(connection: connection, tables: [])
                        
                        sut.delete(entries: [entry, entry2])
                    }
                    it("calls the connection with correct where") {
                        expect(connection.request?.sql).to(equal("DELETE FROM \(TestEntity.tableName) WHERE \(TestEntity.identField)=\(entry.sequenceId) OR \(TestEntity.identField)=\(entry2.sequenceId)"))
                    }
                }
            }
        }
    }
}

//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import Quick
import Nimble
@testable import XrayKit


class SQLConnectionSpecs: QuickSpec {
    let path = "/tmp/xray.sqlite"
    
    override func spec() {
        
        let sut = SQLConnection(path: path)
        
        describe("SQLConnection") {
            
            var result: SQLResult?
            
            beforeEach {
                result = nil
            }
            
            afterEach {
                if FileManager.default.fileExists(atPath: self.path) {
                    try? FileManager.default.removeItem(atPath: self.path)
                }
            }
            
            describe("generic entities") {
            
                // MARK: - PLAIN request
                
                context("when executing a plain request") {
                    
                    beforeEach {
                        result = try? sut.execute(request: EventTable.createRequest)
                    }
                    it("returns a result") {
                        expect(result).notTo(beNil())
                    }
                    
                    it("does not have a insertId") {
                        expect(result?.insertId).to(beNil())
                    }
                }
                
                context("a table is created") {
                    var result: SQLResult?
                    let date = Date()
                    let binds: [String: AnyObject] = [
                        EventTable.columnName: "my_event" as NSString,
                        EventTable.columnStatus: 1 as NSNumber,
                        EventTable.columnProperties: "" as NSString,
                        EventTable.columnUpdatedAt: date.timeIntervalSince1970 as NSNumber,
                        EventTable.columnCreatedAt: date.timeIntervalSince1970 as NSNumber
                    ]
                    beforeEach {
                        result = try? sut.execute(request: EventTable.createRequest)
                    }
                    
                    // MARK: - INSERT request
                    
                    describe("insert request") {
                        beforeEach {
                            do {
                                result = try sut.execute(request: SQLRequest(insertInto: "events", binds: binds))
                            } catch {
                                fail("execute failed: \(error)")
                            }
                            
                        }
                        
                        it("has an insertId") {
                            expect(result?.insertId).notTo(beNil())
                        }
                        
                        it("has correct changed rows count" ) {
                            expect(result?.rowsChanged).to(equal(1))
                        }
                    }

                    // MARK: - SELECT request
                    
                    fcontext("and DB has data") {
                        let allEntries = 50
                        
                        beforeEach {
                            
                            for i in 0..<allEntries {
                                
                                let binds: [String: AnyObject] = [
                                    EventTable.columnName: "my_event" as NSString,
                                    EventTable.columnStatus: i as NSNumber,
                                    EventTable.columnProperties: "" as NSString,
                                    EventTable.columnUpdatedAt: (100 + i) as NSNumber,
                                    EventTable.columnCreatedAt: (200 + i) as NSNumber
                                ]
                                
                                result = try? sut.execute(request: SQLRequest.init(insertInto: "events", binds: binds))
                                expect(result).notTo(beNil()) // just to be sure that we have seed data
                            }
                        }

                        describe("select request") {

                            context("all data") {
                                beforeEach {
                                    result = try? sut.execute(request: SQLRequest(selectFrom: EventTable.tableName))
                                }

                                it("succeeds") {
                                    expect(result).notTo(beNil())
                                }
                                it("has the correct count") {
                                    expect(result?.resultSet?.count).to(equal(allEntries))
                                }
                            }

                            context("one entry") {
                                beforeEach {
                                    result = try? sut.execute(request: SQLRequest(selectFrom: EventTable.tableName, fields: [], whereSQL: "id=1"))
                                }

                                it("succeeds") {
                                    expect(result).notTo(beNil())
                                }
                                it("has the correct count") {
                                    expect(result?.resultSet?.count).to(equal(1))
                                }
                            }
                        }

                        describe("update request") {

                            let updateBinds: [String: AnyObject] = [
                                EventTable.columnStatus: 10 as NSNumber,
                                EventTable.columnUpdatedAt: 20 as NSNumber,
                            ]
                            context("all data") {
                                beforeEach {
                                    result = try? sut.execute(request: SQLRequest(updateTable: EventTable.tableName, binds: updateBinds))
                                }

                                it("succeeds") {
                                    expect(result).notTo(beNil())
                                }
                                it("has the correct count") {
                                    expect(result?.rowsChanged).to(equal(Int32(allEntries)))
                                }
                            }

                            context("some entries") {
                                beforeEach {
                                    result = try? sut.execute(request: SQLRequest(updateTable: EventTable.tableName, binds: updateBinds, whereSQL: "id=1 OR id=2"))
                                }

                                it("succeeds") {
                                    expect(result).notTo(beNil())
                                }
                                it("has the correct count") {
                                    expect(result?.rowsChanged).to(equal(2))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

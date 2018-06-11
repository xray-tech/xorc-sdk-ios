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
            
            context("event table is created") {
                var result: SQLResult?
                let date = Date()
                let binds: [String: AnyObject] = [
                    "name": "my_event" as NSString,
                    "status": 1 as NSNumber,
                    "payload": "" as NSString,
                    "updatedAt": date.timeIntervalSince1970 as NSNumber,
                    "createdAt": date.timeIntervalSince1970 as NSNumber
                ]
                beforeEach {
                    result = try? sut.execute(request: EventTable.createRequest)
                }
                
                // MARK: - INSERT request
                
                describe("insert request") {
                    beforeEach {
                            result = try? sut.execute(request: SQLRequest(insertInto: "events", binds: binds))
                    }
                    
                    it("has an insertId") {
                        expect(result?.insertId).notTo(beNil())
                    }
                    
                    it("has correct changed rows count" ) {
                        expect(result?.rowsChanged).to(equal(1))
                    }
                }
            }
        }
    }
}

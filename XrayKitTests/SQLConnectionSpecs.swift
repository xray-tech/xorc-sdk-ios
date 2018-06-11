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
                    let table = EventTable()
                    result = try? sut.execute(request: table.createRequest)
                }
                it("returns a result") {
                    expect(result).notTo(beNil())
                }
                
                it("does not have a insertId") {
                    expect(result!.insertId).to(equal(0))
                }
            }
            
            // MARK: - INSERT request
            context("event table is created") {
                beforeEach {
                    _ = try? sut.execute(request: EventTable().createRequest)
                }
                
                
                describe("insert request") {
                    
                    beforeEach {
                        
                    }
                }
                
            }
        }
    }
}

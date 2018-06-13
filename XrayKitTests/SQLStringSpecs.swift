//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import Quick
import Nimble

@testable import XrayKit

class SQLStringSpecs: QuickSpec {
    
    override func spec() {
        
        describe("SQLStrings") {
            var result: String?
            
            describe("when generating INSERT SQL") {
                context("and given valid parameters") {
                    beforeEach {
                        result = String.sqlInsert(tableName: "events", fields: ["status", "updatedAt"])
                    }
                    
                    it("it generates a valid SQL") {
                        expect(result).to(equal("INSERT INTO events (status, updatedAt) VALUES (:status, :updatedAt)"))
                    }
                }
            }
            
            describe("when generating SELECT SQL") {
                
                let fields = ["status", "updatedAt"]
                let order = [
                    ("status", SQLRequest.Order.asc),
                    ("updatedAt", SQLRequest.Order.desc)
                ]
                context("and given a table name") {
                    beforeEach {
                        result = String.sqlSelect(tableName: "events")
                    }
                    
                    it("generates a valid SQL") {
                        expect(result).to(equal("SELECT * FROM events"))
                    }
                }
                
                context("and given a table name with fields") {
                    beforeEach {
                        result = String.sqlSelect(tableName: "events", fields: fields)
                    }
                    
                    it("generates a valid SQL") {
                        expect(result).to(equal("SELECT status, updatedAt FROM events"))
                    }
                }
                
                context("and given a WHERE clause") {
                    beforeEach {
                        result = String.sqlSelect(tableName: "events", fields: fields, whereSQL: "status=1", order: order)
                    }
                    
                    it("generates a valid SQL") {
                        expect(result).to(equal("SELECT status, updatedAt FROM events WHERE status=1 ORDER BY status ASC, updatedAt DESC"))
                    }
                }
            }
        }
    }
}

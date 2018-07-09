//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import Nimble
import Quick
@testable import XrayKit

class DataPayloadSpecs: QuickSpec {
    override func spec() {
        
        describe("DataPayload") {
            context("with a date trigger") {
                let date = Date()
                let data = "hello".data(using: .utf8)!
                let sut = DataPayload(data: data, trigger: .date(date))
                
                describe("binds") {
                    
                    it("contains createdAt") {
                        expect(sut.binds[DataTable.columnCreatedAt] as? NSNumber).notTo(equal(0))
                    }
                    
                    it("contains updatedAt") {
                        expect(sut.binds[DataTable.columnUpdatedAt] as? NSNumber).notTo(equal(0))
                    }
                    
                    it("contains executeAt") {
                        expect(sut.binds[DataTable.columnExecuteAt] as? NSNumber).to(equal(date.timeIntervalSince1970 as NSNumber))
                    }
                    
                    it("contains the data") {
                        expect(sut.binds[DataTable.columnData]).notTo(beNil())
                    }
                    
                    it("does not contains eventName") {
                        expect(sut.binds[DataTable.columnEventName]).to(beNil())
                    }
                    it("does not contains eventName") {
                        expect(sut.binds[DataTable.columnEventFilter]).to(beNil())
                    }
                }
            }
            
            context("with a event trigger") {
                let data = "hello".data(using: .utf8)!
                
                let filters = """
                {"event.properties.item_name":{"eq":"iPhone"}}
                """.data(using: .utf8)!
                
                let eventTrigger = try! EventTrigger(name: "my_event", jsonFilters: filters)
                let sut = DataPayload(data: data, trigger: .event(eventTrigger))
                
                describe("binds") {
                    
                    it("contains createdAt") {
                        expect(sut.binds[DataTable.columnCreatedAt] as? NSNumber).notTo(equal(0))
                    }
                    
                    it("contains updatedAt") {
                        expect(sut.binds[DataTable.columnUpdatedAt] as? NSNumber).notTo(equal(0))
                    }
                    
                    it("does not contain executeAt") {
                        expect(sut.binds[DataTable.columnExecuteAt]).to(beNil())
                    }
                    
                    it("contains the data") {
                        expect(sut.binds[DataTable.columnData]).notTo(beNil())
                    }
                    
                    it("contains the eventName") {
                        expect(sut.binds[DataTable.columnEventName] as? String).to(equal("my_event"))
                    }
                    it("contains eventFilters") {
                        expect(sut.binds[DataTable.columnEventFilter]).notTo(beNil())
                    }
                }
            }
        }
    }
}

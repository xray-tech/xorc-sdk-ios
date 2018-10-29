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
            
            let filters = """
                        {"event.properties.item_name":{"eq":"iPhone"}}
                    """.data(using: .utf8)!
            let eventTrigger = try! EventTrigger(name: "my_event", jsonFilters: filters)
            
            describe("when serializing") {
                
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
            
            describe("when deserialising") {
                var originalData: DataPayload!
                var deserializedPayload: DataPayload?
                
                context("with an event trigger with filters") {
                    beforeEach {
                        originalData = DataPayload(data: "hello".data(using: .utf8)!,
                                                   trigger: .event(eventTrigger),
                                                   userInfo: nil,
                                                   expiresAt: Date(),
                                                   entryId: 10,
                                                   createdAt: Date(),
                                                   updatedAt: Date())
                        
                        deserializedPayload = try? DataPayload.deserialize(originalData.binds)
                    }
                    
                    it("retuns a non nil payload") {
                        expect(deserializedPayload).notTo(beNil())
                    }
                    
                    it("has the correct properties") {
                        expect(deserializedPayload?.sequenceId).to(equal(originalData.sequenceId))
                        expect(deserializedPayload?.createdAt.timeIntervalSince1970).to(equal(originalData.createdAt.timeIntervalSince1970))
                        expect(deserializedPayload?.updatedAt.timeIntervalSince1970).to(equal(originalData.updatedAt.timeIntervalSince1970))
                    }
                }
                
                context("with an event trigger without filters") {
                    beforeEach {
                        originalData = DataPayload(data: "hello".data(using: .utf8)!,
                                                   trigger: .event(EventTrigger(name: "my_event")),
                                                   userInfo: nil,
                                                   expiresAt: Date(),
                                                   entryId: 10,
                                                   createdAt: Date(),
                                                   updatedAt: Date())
                        
                        deserializedPayload = try? DataPayload.deserialize(originalData.binds)
                    }
                    
                    it("retuns a non nil payload") {
                        expect(deserializedPayload).notTo(beNil())
                    }
                    
                    it("has the correct properties") {
                        expect(deserializedPayload?.sequenceId).to(equal(originalData.sequenceId))
                        expect(deserializedPayload?.createdAt.timeIntervalSince1970).to(equal(originalData.createdAt.timeIntervalSince1970))
                        expect(deserializedPayload?.updatedAt.timeIntervalSince1970).to(equal(originalData.updatedAt.timeIntervalSince1970))
                    }
                }
                
                context("with a date trigger") {
                    beforeEach {
                        originalData = DataPayload(data: "hello".data(using: .utf8)!,
                                                   trigger: .date(Date()),
                                                   userInfo: nil,
                                                   expiresAt: Date(),
                                                   entryId: 10,
                                                   createdAt: Date(),
                                                   updatedAt: Date())
                        
                        deserializedPayload = try? DataPayload.deserialize(originalData.binds)
                    }
                    
                    it("retuns a non nil payload") {
                        expect(deserializedPayload).notTo(beNil())
                    }
                    
                    it("has the correct properties") {
                        expect(deserializedPayload?.sequenceId).to(equal(originalData.sequenceId))
                        expect(deserializedPayload?.createdAt.timeIntervalSince1970).to(equal(originalData.createdAt.timeIntervalSince1970))
                        expect(deserializedPayload?.updatedAt.timeIntervalSince1970).to(equal(originalData.updatedAt.timeIntervalSince1970))
                    }
                }
            }
        }
    }
}

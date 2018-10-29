//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import Nimble
import Quick
@testable import XrayKit

class SQLEventSpecs: QuickSpec {
    override func spec() {
        
        describe("SQL event") {
            context("without properties") {
                let sut = Event(name: "my_event")
                
                describe("binds") {
                    it("contains name") {
                        expect(sut.binds["name"] as? String).to(equal("my_event"))
                    }
                    
                    it("contains createdAt") {   
                        expect(sut.binds[EventTable.columnCreatedAt] as? NSNumber).notTo(equal(0))
                    }
                    
                    it("contains updatedAt") {
                        expect(sut.binds[EventTable.columnUpdatedAt] as? NSNumber).notTo(equal(0))
                    }
                    
                    it("does not contain properties") {
                        expect(sut.binds[EventTable.columnProperties]).to(beNil())
                    }
                    
                    it("does not contain context") {
                        expect(sut.binds[EventTable.columnContext]).to(beNil())
                    }
                }
            }
            
            describe("when serialising nextRetryAt") {
                var sut: Event!
                context("without nextRetryAt") {
                    
                    beforeEach {
                       sut = Event(name: "my_event")
                    }
                    
                    describe("binds") {
                        it("do not contain nextRetryAt") {
                            expect(sut.binds[EventTable.columnNextTryAt]).to(beNil())
                        }
                    }
                }
                
                context("without nextRetryAt") {
                    beforeEach {
                        sut = Event(name: "my_event")
                        sut.nextRetryAt = Date()
                    }
                    
                    describe("binds") {
                        it("do not contain nextRetryAt") {
                            expect(sut.binds[EventTable.columnNextTryAt] as? NSNumber).notTo(equal(0))
                        }
                    }
                }
            }

            context("with properties") {
                let expectedProperties: [String: JSONValue] = [
                    "myStringKey": JSONValue("myStringValue"),
                    "myNumberValue": JSONValue(10)
                ]
                var sut = Event(name: "my_event", properties: expectedProperties, context: expectedProperties)

                describe("binds") {
                    it("contains a properties") {
                        expect(sut.binds[EventTable.columnProperties]).notTo(beNil())
                    }
                    
                    it("contains a context") {
                        expect(sut.binds[EventTable.columnContext]).notTo(beNil())
                    }
                    
                    it("contains properties as String") {
                        expect(sut.binds[EventTable.columnProperties]).to(beAKindOf(NSString.self))
                    }
                    
                    describe("when deserialize properties") {
                        var properties: [String: AnyObject]?
                        beforeEach {
                            if
                                let json = sut.binds[EventTable.columnProperties] as? NSString,
                                let object = try? JSONSerialization.jsonObject(with: json.data(using: 0)!, options: [])
                                {
                                    properties = object as? [String: AnyObject]
                                }
                        }
                        
                        it("contains the same properties count") {
                            expect(properties).to(haveCount(expectedProperties.count))
                        }
                    }
                }
                describe("when using Updatable") {
                    let updatedAt = sut.updatedAt
                    var updateRequest: SQLRequest!

                    beforeEach {
                        updateRequest = sut.updateRequest()
                    }
                    it("sets a new updatedAt to the event") {
                        expect(sut.updatedAt).to(beGreaterThan(updatedAt))
                    }

                    it("creates a request with a where clause") {
                        expect(updateRequest.sql).to(contain("WHERE \(EventTable.columnId)=\(sut.sequenceId)"))
                    }
                }
            }

            describe("when generating SQL") {
                var sql: String?

                let date = Date()

                describe("sendable events") {

                    context("without priority") {
                        beforeEach {
                            sql = Event.whereSendableSQL(maxNextTryAt: date)
                        }
                        it("generates the correct SQL") {
                            expect(sql).to(equal("(\(EventTable.columnStatus) = \(Event.Status.queued.rawValue) OR \(EventTable.columnStatus) = \(Event.Status.retry.rawValue)) AND \(EventTable.columnNextTryAt) <= \(date.timeIntervalSince1970)"))
                        }
                    }

                    context("with priority") {
                        beforeEach {
                            sql = Event.whereSendableSQL(maxNextTryAt: date, priority: .important)
                        }
                        it("generates the correct SQL") {
                            expect(sql).to(equal("(\(EventTable.columnStatus) = \(Event.Status.queued.rawValue) OR \(EventTable.columnStatus) = \(Event.Status.retry.rawValue)) AND \(EventTable.columnNextTryAt) <= \(date.timeIntervalSince1970) AND \(EventTable.columnPriority) = \(Event.Priority.important.rawValue)"))
                        }
                    }
                }
            }
            
            describe("when deserialising SQL") {
                var originalEvent: Event!
                var deserializedEvent: Event?
                
                context("with a valid binds") {
                    beforeEach {
                        originalEvent = Event(name: "my_event", properties: ["foo": JSONValue("bar")])
                        originalEvent.sequenceId = 10
                        
                        deserializedEvent = try? Event.deserialize(originalEvent.binds)
                    }
                    
                    it("retuns a non nil event") {
                        expect(deserializedEvent).notTo(beNil())
                    }
                    
                    it("set the event properties") {
                        expect(deserializedEvent?.sequenceId).to(equal(originalEvent.sequenceId))
                        expect(deserializedEvent?.createdAt.timeIntervalSince1970).to(equal(originalEvent.createdAt.timeIntervalSince1970))
                        expect(deserializedEvent?.updatedAt.timeIntervalSince1970).to(equal(originalEvent.updatedAt.timeIntervalSince1970))
                        expect(deserializedEvent?.properties?.count).to(equal(originalEvent.properties?.count))
                    }
                }
            }
        }
    }
}

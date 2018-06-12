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
                }
            }

            context("with properties") {
                let expectedProperties: [String: Codable] = [
                    "myStringKey": "myStringValue",
                    "myNumberValue": 10
                ]
                let sut = Event(name: "my_event", properties: expectedProperties)

                describe("binds") {
                    it("contains a properties") {
                        expect(sut.binds[EventTable.columnProperties]).notTo(beNil())
                    }
                    
                    it("contains properties as String") {
                        expect(sut.binds[EventTable.columnProperties]).to(beAKindOf(NSString.self))
                    }
                    
                    describe("when deserialise properties") {
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
            }
        }
    }
}

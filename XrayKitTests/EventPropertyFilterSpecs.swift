//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Quick
import Nimble

@testable import XrayKit

class EventPropertyFilterSpecs: QuickSpec {
    override func spec() {
        describe("EventPropertyFilter") {
            let sut = EventPropertyFilter.self
            
            var result: FilterResult!
            
            context("given one payload with a different event name") {
                
                let payload = DataPayload(data: "".data(using: .utf8)!, trigger: .event(EventTrigger(name: "my_event")))
                let event = Event(name: "no_name")
                beforeEach {
                    result = sut.filter(payloads: [payload], withEvent: event)
                }
                
                it("has a mismatched result with keep handle") {
                    expect(result.mismatched.count).to(equal(1))
                    expect(result.mismatched.first!.handle).to(equal(.keep))
                }
                
                it("has no matched result") {
                    expect(result.matched.count).to(equal(0))
                }
            }
            
            context("given one non event trigger") {
                
                let payload = DataPayload(data: "".data(using: .utf8)!, trigger: .date(Date()))
                let event = Event(name: "no_name")
                beforeEach {
                    result = sut.filter(payloads: [payload], withEvent: event)
                }
                
                it("has a mismatched result with keep handle") {
                    expect(result.mismatched.count).to(equal(1))
                    expect(result.mismatched.first!.handle).to(equal(.keep))
                }
                
                it("has no matched result") {
                    expect(result.matched.count).to(equal(0))
                }
            }
            
            context("given a matching event name") {
                
                let name = "my_event"
                
                context("and a trigger without filters") {
                    
                    let payload = DataPayload(data: "".data(using: .utf8)!, trigger: .event(EventTrigger(name: "my_event")))
                    let event = Event(name: name)
                    beforeEach {
                        result = sut.filter(payloads: [payload], withEvent: event)
                    }

                    it("has one matched result") {
                        expect(result.matched.count).to(equal(1))
                    }
                    
                    it("has no mismatched result") {
                        expect(result.mismatched.count).to(equal(0))
                    }
                }
                
                context("and a trigger with a non matching filter") {
                    
                    let trigger = EventTrigger(name: name, filters: ["event.properties.item_name": [ "eq": "iPhone" ]])
                    let payload = DataPayload(data: "".data(using: .utf8)!, trigger: .event(trigger))
                    let event = Event(name: name, properties: ["item_name": "Galaxy"])
                    beforeEach {
                        result = sut.filter(payloads: [payload], withEvent: event)
                    }
                    
                    it("has one mismatched result with keep handle") {
                        expect(result.mismatched.count).to(equal(1))
                        expect(result.mismatched.first!.handle).to(equal(.keep))
                    }
                    
                    it("has no matched result") {
                        expect(result.matched.count).to(equal(0))
                    }
                }
                
                context("and a trigger with a matching filter") {
                    
                    let trigger = EventTrigger(name: name, filters: ["event.properties.item_name": [ "eq": "iPhone" ]])
                    let payload = DataPayload(data: "".data(using: .utf8)!, trigger: .event(trigger))
                    let event = Event(name: name, properties: ["item_name": "iPhone"])
                    beforeEach {
                        result = sut.filter(payloads: [payload], withEvent: event)
                    }
                    
                    it("has one matched result") {
                        expect(result.matched.count).to(equal(1))
                    }
                    
                    it("has a no mismatched result") {
                        expect(result.mismatched.count).to(equal(0))
                    }
                }
                
                context("and a trigger with an invalid filter") {
                    
                    let trigger = EventTrigger(name: name, filters: ["event.properties.item_name": [ ]])
                    let payload = DataPayload(data: "".data(using: .utf8)!, trigger: .event(trigger))
                    let event = Event(name: name, properties: ["item_name": "iPhone"])
                    beforeEach {
                        result = sut.filter(payloads: [payload], withEvent: event)
                    }
                    
                    it("has one mismatched result with a delete handle") {
                        expect(result.mismatched.count).to(equal(1))
                        expect(result.mismatched.first!.handle).to(equal(.delete))
                    }
                    
                    it("has no matched result") {
                        expect(result.matched.count).to(equal(0))
                    }
                }
            }
        }
    }
}

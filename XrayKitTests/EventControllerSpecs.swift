import Quick
import Nimble

@testable import XrayKit



class EventControllerSpecs: QuickSpec {
    
    override func spec() {
        
        describe("EventController") {
            
            var sut: EventController!
            var transmitter: MockTrasnmitter!
            var store: MemoryEventStore!
            
            beforeEach {
                transmitter = MockTrasnmitter()
                store = MemoryEventStore()
                
                sut = EventController(eventStore: store, transmitter: transmitter)
            }
            
            describe("when using a different event scope") {
                
                context("given a local event") {
                    
                    beforeEach {
                        sut.log(event: Event(name: "my_event", properties: nil, scope: .local))
                    }
                    
                    it("is not transmitted") {
                        expect(transmitter.events).to(beEmpty())
                    }
                    
                    it("is not persisted") {
                        expect(store.events).to(beEmpty())
                    }
                }
                
                context("given a remote event") {
                    
                    let event = Event(name: "my_event")
                    
                    context("and the event is flushed") {
                        
                        beforeEach {
                            sut.log(event: event)
                        }
                        
                        it("it is transmitted") {
                          expect(transmitter.events).to(contain(event))
                        }
                        
                        it("is persisted") {
                            expect(store.events).to(contain(event))
                        }
                    }
                    
                    context("and the event is not flushed") {
                        
                        beforeEach {
                            sut.log(event: event, flush: false)
                        }
                        
                        it("it is not transmitted") {
                            expect(transmitter.events).to(beEmpty())
                        }
                        
                        it("is persisted") {
                            expect(store.events).to(contain(event))
                        }
                    }
                }
            }
        }
    }
}

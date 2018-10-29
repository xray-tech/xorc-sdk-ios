import Quick
import Nimble

@testable import XrayKit



class EventControllerSpecs: QuickSpec {
    
    override func spec() {
        
        describe("EventController") {
            
            var sut: EventController!
            var transmitter: MockTrasnmitter!
            var store: MemoryEventStore!
            
            let event = Event(name: "my_event")
            
            beforeEach {
                transmitter = MockTrasnmitter()
                store = MemoryEventStore()
                
                sut = EventController(eventStore: store)
                sut.transmitter = transmitter
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
            
            describe("when transmitting events") {
                
                context("and the transmitter succeeds") {
                    
                    beforeEach {
                        transmitter = MockTrasnmitter(behaviour: .succeed)
                        
                        sut = EventController(eventStore: store)
                        sut.transmitter = transmitter
                        
                        sut.log(event: event)
                    }
                    
                    it("tells the store to delete the events") {
                        expect(store.deleted).to(contain(event))
                    }
                }
                
                context("and the transmitter fails") {
                    
                    beforeEach {
                        transmitter = MockTrasnmitter(behaviour: .fail)

                        sut = EventController(eventStore: store)
                        sut.transmitter = transmitter
                        
                        sut.log(event: event)
                    }
                    
                    it("tells the store to delete the event") {
                        expect(store.deleted).to(contain(event))
                    }
                }
                
                context("and the transmitter retries") {
                    
                    let expectedNextRetryAt = Date.distantFuture
                    beforeEach {
                        transmitter = MockTrasnmitter(behaviour: .retry(nextRetryAt: expectedNextRetryAt))
                        
                        sut = EventController(eventStore: store)
                        sut.transmitter = transmitter
                        
                        sut.log(event: event)
                    }
                    
                    it("tells the store to update the event") {
                        expect(store.updated).to(contain(event))
                    }
                    
                    it("sets the nextRetryAt date") {
                        expect(store.updated.first?.nextRetryAt).to(equal(expectedNextRetryAt))
                    }
                    
                    it("sets the event status to retry") {
                        expect(store.updated.first?.status).to(equal(Event.Status.retry))
                    }
                }
            }
        }
    }
}

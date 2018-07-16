import Quick
import Nimble
@testable import XrayKit

class NSPredicateSpecs: QuickSpec {

    override func spec() {

        describe("NSPredicate") {

            var xoperator: String!
            var predicate: NSPredicate!
            var predicateProxy: PredicateProxy!

            // MARK: - CONTAINS

            describe("given contains operator") {

                beforeEach {
                    xoperator = "contains"
                }
                context("and a string argument") {

                    beforeEach {
                        predicate = NSPredicate.predicateWithValueKeyPath(valueKeyPath: "event.properties.item_name", xoperator: xoperator, arguments: "iPho")
                    }

                    context("and a value that contains") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "iPhone"]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }

                    context("and a value that does not contains") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "Samsung"]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }
                }
            }

            describe("given not_contains operator") {

                beforeEach {
                    xoperator = "not_contains"
                }
                context("and a string argument") {

                    beforeEach {
                        predicate = NSPredicate.predicateWithValueKeyPath(valueKeyPath: "event.properties.item_name", xoperator: xoperator, arguments: "iPho")
                    }

                    context("and a value that contains") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "iPhone"]))
                        }

                        it("evaluates to false") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }

                    context("and a value that does not contains") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "Samsung"]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }
                }
            }

            describe("given contains operator") {

                beforeEach {
                    xoperator = "contains"
                }
                context("and a string argument") {

                    beforeEach {
                        predicate = NSPredicate.predicateWithValueKeyPath(valueKeyPath: "event.properties.item_name", xoperator: xoperator, arguments: "iPho")
                    }

                    context("and a value that contains") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "iPhone"]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }

                    context("and a value that does not contains") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "Samsung"]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }
                }
            }

            // MARK: - IN

            describe("given in operator") {

                beforeEach {
                    xoperator = "in"
                }
                context("and a string array argument") {

                    beforeEach {
                        predicate = NSPredicate.predicateWithValueKeyPath(valueKeyPath: "event.properties.item_name", xoperator: xoperator, arguments: ["iPhone"])
                    }

                    context("and a value that is contained") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "iPhone"]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }

                    context("and a value that does not contains") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "Samsung"]))
                        }

                        it("evaluates to false") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }
                }
            }

            describe("given 'not_in' operator") {

                beforeEach {
                    xoperator = "not_in"
                }
                context("and a string array argument") {

                    beforeEach {
                        predicate = NSPredicate.predicateWithValueKeyPath(valueKeyPath: "event.properties.item_name", xoperator: xoperator, arguments: ["iPhone"])
                    }

                    context("and a value that is contained") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "iPhone"]))
                        }

                        it("evaluates to false") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }

                    context("and a value that does not contains") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "Samsung"]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }
                }
            }

            // MARK: - EQ

            describe("given 'eq' operator") {

                beforeEach {
                    xoperator = "eq"
                }
                context("and a string argument") {

                    beforeEach {
                        predicate = NSPredicate.predicateWithValueKeyPath(valueKeyPath: "event.properties.item_name", xoperator: xoperator, arguments: "10")
                    }

                    context("and a string that equals") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "10"]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }

                    context("and string value that does not equal") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "11"]))
                        }

                        it("evaluates to false") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }

                    context("and a non string value that equals") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": 10]))
                        }

                        it("evaluates to false (types don't match)") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }
                }

                context("and a bool argument") {

                    beforeEach {
                        predicate = NSPredicate.predicateWithValueKeyPath(valueKeyPath: "event.properties.item_name", xoperator: xoperator, arguments: true)
                    }

                    context("and a bool that equals") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": true]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }

                    context("and bool value that does not equal") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": false]))
                        }

                        it("evaluates to false") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }

                    context("and a string boolean value that equals") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "true"]))
                        }

                        it("evaluates to false (types don't match)") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }

                    context("and a non boolean value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": 11]))
                        }

                        it("evaluates to false") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }
                }
            }

            // MARK: - GT

            describe("given gt operator") {

                beforeEach {
                    xoperator = "gt"
                }
                context("and a number argument") {

                    beforeEach {
                        predicate = NSPredicate.predicateWithValueKeyPath(valueKeyPath: "event.properties.count", xoperator: xoperator, arguments: 10)
                    }

                    context("and a greater number value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["count": 11]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }

                    context("and a lower number value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["count": 9]))
                        }

                        it("evaluates to false") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }

                    context("and a equal number value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["count": 10]))
                        }

                        it("evaluates to false") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }
                }
            }

            // MARK: - GTE

            describe("given gte operator") {

                beforeEach {
                    xoperator = "gte"
                }
                context("and a number argument") {

                    beforeEach {
                        predicate = NSPredicate.predicateWithValueKeyPath(valueKeyPath: "event.properties.count", xoperator: xoperator, arguments: 10)
                    }

                    context("and a greater number value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["count": 11]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }

                    context("and a lower number value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["count": 9]))
                        }

                        it("evaluates to false") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }

                    context("and a equal number value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["count": 10]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }
                }
            }

            // MARK: - LT

            describe("given lt operator") {

                beforeEach {
                    xoperator = "lt"
                }
                context("and a number argument") {

                    beforeEach {
                        predicate = NSPredicate.predicateWithValueKeyPath(valueKeyPath: "event.properties.count", xoperator: xoperator, arguments: 10)
                    }

                    context("and a greater number value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["count": 11]))
                        }

                        it("evaluates to false") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }

                    context("and a lower number value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["count": 9]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }

                    context("and a equal number value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["count": 10]))
                        }

                        it("evaluates to false") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }
                }
            }

            // MARK: - LTE

            describe("given lte operator") {

                beforeEach {
                    xoperator = "lte"
                }
                context("and a number argument") {

                    beforeEach {
                        predicate = NSPredicate.predicateWithValueKeyPath(valueKeyPath: "event.properties.count", xoperator: xoperator, arguments: 10)
                    }

                    context("and a greater number value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["count": 11]))
                        }

                        it("evaluates to false") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                        }
                    }

                    context("and a lower number value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["count": 9]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }

                    context("and a equal number value") {
                        beforeEach {
                            predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["count": 10]))
                        }

                        it("evaluates to true") {
                            expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                        }
                    }
                }
            }
        }
    }
}

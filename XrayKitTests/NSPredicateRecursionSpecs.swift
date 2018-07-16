import Quick
import Nimble
@testable import XrayKit

class NSPredicateRecursionSpecs: QuickSpec {

    override func spec() {

        describe("NSPredicate") {

            var predicate: NSPredicate!
            var predicateProxy: PredicateProxy!

            context("given a simple filter") {

                beforeEach {
                    let filters = JSONObjectForFile(fileName: "event-filter-simple.json", aClass: type(of: self))["filters"] as! [String: Any]
                    predicate = try? NSPredicate.makePredicate(filters: filters)
                }

                it("returns a comparison predicate") {
                    expect(predicate).to(beAKindOf(NSComparisonPredicate.self))
                }

                context("and a matching object") {

                    beforeEach {
                        predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "iPhone"]))
                    }
                    it("it evaluates to true") {
                        expect(predicate.evaluate(with: predicateProxy)).to(beTrue())
                    }
                }

                context("and a non matching object") {

                    beforeEach {
                        predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: ["item_name": "Samsubg"]))
                    }
                    it("it evaluates to false") {
                        expect(predicate.evaluate(with: predicateProxy)).to(beFalse())
                    }
                }
            }
        }
    }
}

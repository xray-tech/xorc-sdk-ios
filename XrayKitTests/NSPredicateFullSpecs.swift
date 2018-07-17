import Foundation
import Nimble
import Quick
@testable import XrayKit

class NSPredicateFullSpecs: QuickSpec {

    override func spec() {

        fdescribe("NSPredicateFullSpecs") {
            var predicate: NSPredicate!
            var predicateProxy: PredicateProxy!
            var expectedMatch: Bool!

            let fileNames = ["full-test-filter-1.json", "full-test-filter-2.json", "full-test-filter-3.json"]

            for fileName in fileNames {
                context("given file name \(fileName)") {
                    beforeEach {
                        let testDefinitionJson = JSONObjectForFile(fileName: fileName, aClass: type(of: self))

                        expectedMatch = testDefinitionJson["matches"] as? Bool
                        let filters = testDefinitionJson["filters"] as! [String: Any]
                        predicate = try? NSPredicate.makePredicate(filters: filters)
                        let properties = (testDefinitionJson as NSDictionary).value(forKeyPath: "event.properties") as! [String: Any]

                        predicateProxy = PredicateProxy(event: Event(name: "my_event", properties: properties.jsonValues()))
                    }

                    it("evaluates the filter correctly") {
                        expect(predicate.evaluate(with: predicateProxy)).to(equal(expectedMatch))
                    }
                }
            }
        }
    }
}

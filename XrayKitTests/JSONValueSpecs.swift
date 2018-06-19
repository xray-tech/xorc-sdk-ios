import Quick
import Nimble

@testable import XrayKit

class JSONValueSpecs: QuickSpec {
    
    override func spec() {
        
        
        describe("JSONValue") {
            
            describe("when decoding") {
                let decoder = JSONDecoder()
                var result: [String: JSONValue]?
                context("a valid json") {
                    let json = """
                        {
                        "string": "hello",
                        "integer": 1,
                        "double": 1.1,
                        "boolean": true
                        }
                    """.data(using:.utf8)!
                    
                    beforeEach {
                        result = try? decoder.decode([String: JSONValue].self, from: json)
                    }
                    
                    it("does not throw") {
                        expect(result).notTo(beNil())
                    }
                    it("decodes a string") {
                        let current = result!["string"]!
                        switch current {
                        case .string(let value):
                            expect(value).to(equal("hello"))
                        default:
                            fail("Expected a string value")
                        }
                    }
                    
                    it("decodes a integer") {
                        let current = result!["integer"]!
                        switch current {
                        case .integer(let value):
                            expect(value).to(equal(1))
                        default:
                            fail("Expected a integer value")
                        }
                    }
                    
                    it("decodes a double") {
                        let current = result!["double"]!
                        switch current {
                        case .double(let value):
                            expect(value).to(equal(1.1))
                        default:
                            fail("Expected a double value")
                        }
                    }
                    
                    it("decodes a boolean") {
                        let current = result!["boolean"]!
                        switch current {
                        case .bool(let value):
                            expect(value).to(beTrue())
                        default:
                            fail("Expected a bool value")
                        }
                    }
                }
            }
        }
    }
}

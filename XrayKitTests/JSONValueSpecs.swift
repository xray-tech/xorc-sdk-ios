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
            
            describe("when encoding") {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                
                var result: String?
                
                context("a valid json") {
                   
                    let json: [String: JSONValue] = [
                        "string": JSONValue("hello"),
                        "integer": JSONValue(1),
                        "double": JSONValue(1.1),
                        "bool": JSONValue(true)
                    ]
                    
                    beforeEach {
                        if let data = try? encoder.encode(json) {
                            result = String(data: data, encoding: .utf8)
                        }
                    }
                    
                    it("does not throw") {
                        expect(result).notTo(beNil())
                    }
                    
                    it("decodes a string") {
                        expect(result).to(contain("\"string\" : \"hello\""))
                    }
                    
                    it("decodes a integer") {
                        expect(result).to(contain("\"integer\" : 1"))
                    }

                    
                    it("decodes a double") {
                        expect(result).to(contain("\"double\" : 1.1"))
                    }
                    
                    it("decodes a boolean") {
                        expect(result).to(contain("\"bool\" : true"))
                    }
                }
            }
        }
    }
}

//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

enum ParsingError: Error {
    case invalidJSON(String)
}
public enum JSONValue: Codable {
    case string(String)
    case integer(Int)
    case double(Double)
    case bool(Bool)
    
    public init(_ value: String) {
        self = .string(value)
    }
    
    public init(_ value: Int) {
        self = .integer(value)
    }
    
    public init(_ value: Double) {
        self = .double(value)
    }
    
    public init(_ value: Bool) {
        self = .bool(value)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .integer(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else {
            throw ParsingError.invalidJSON("Not a JSON value at path '\(container.codingPath)'")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .integer(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        }
    }
}

extension JSONValue: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByBooleanLiteral {
    
    public init(stringLiteral value: String) {
        self = .string(value)
    }
    
    public init(integerLiteral value: Int) {
        self = .integer(value)
    }
    
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
    
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSONValue {

    /**
        Convenience initializer to parse a `String` into a `Bool, `Int`, `Double` before falling back to a `String`
        - `false` or `true` are parsed in to a Bool
        - Integer numbers into a `Int` e.g. `"1"`
        - Decimal numbers into a `Double` e.g. `"1.0"`, `"1.1"`, ...
    */
    public init(parseString stringValue: String) {
        
        if let value = Bool(stringValue) {
            self.init(value)
        } else if let value = Int(stringValue) {
            self.init(value)
        } else if let value = Double(stringValue) {
            self.init(value)
        } else {
            self.init(stringValue)
        }
    }
   
    /// Helper var to get the Bool value. Returns nil if this is not a Bool value
    public var boolValue: Bool? {
        if case let .bool(val) = self {
            return val
        }
        return nil
    }

    var anyValue: Any {
        switch self {
        case .string(let val):
            return val
        case .integer(let val):
            return val
        case .double(let val):
            return val
        case .bool(let val):
            return val
        }
    }
    
    /// Helper var to get the String value returns nil otherwise
    public var stringValue: String? {
        if case let .string(val) = self {
            return val
        }
        return nil
    }
    
    /// Helper var to get the Double value returns nil otherwise
    public var doubleValue: Double? {
        if case let .double(val) = self {
            return val
        }
        return nil
    }
    
    /// Helper var to get the Integer value returns nil otherwise
    public var integerValue: Int? {
        if case let .integer(val) = self {
            return val
        }
        return nil
    }
}

public extension Dictionary where Key == String, Value == JSONValue {

    /**
     Helper method to encode into a JSON string
     - parameter prettyPrint: Produce human-readable JSON with indented output. Default is `true`
     
     - throws: When the type cannot be decoded or when the data cannot be encoded in utf8.
    */
    func toJson(prettyPrint: Bool = true) throws -> String {
        let encoder = JSONEncoder()
        if prettyPrint {
            encoder.outputFormatting = [.prettyPrinted]
        }

        let data = try encoder.encode(self.self)
        guard let string = String(bytes: data, encoding: .utf8) else {
            throw ParsingError.invalidJSON("Could not decode json bytes")
        }
        return string
    }
}
extension Dictionary where Key == String, Value == Any {

    /**
     Helper method to convert a Dictionary with Any values into a `JSONValue`.
     
     - Warning: Any values that are not `Int`, `Bool`, `Double` or `String` will be silently removed
     
    */
    func jsonValues() -> [String: JSONValue] {
        var jsonValues = [String: JSONValue]()
        
        for (key, value) in self {
            switch value {
            case let value as Int:
                jsonValues[key] = JSONValue.init(value)
            case let value as String:
                jsonValues[key] = JSONValue.init(value)
            case let value as Double:
                jsonValues[key] = JSONValue.init(value)
            case let value as Bool:
                jsonValues[key] = JSONValue.init(value)
            default:
                continue
            }
        }
        return jsonValues
    }
}

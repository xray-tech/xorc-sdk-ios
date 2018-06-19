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
    
    init(_ value: Int) {
        self = .integer(value)
    }
    
    init(_ value: Double) {
        self = .double(value)
    }
    
    init(_ value: Bool) {
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

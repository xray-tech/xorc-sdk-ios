//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

// todo doc
public struct EventTrigger {
    public let name: String
    public let filters: [String: Any]?
    
    public init(name: String, filters: [String: Any]? = nil) {
        self.name = name
        self.filters = filters
    }
}

extension EventTrigger {
    
    public init(name: String, jsonFilters: String) throws {
        guard let data = jsonFilters.data(using: .utf8) else {
            throw ParsingError.invalidJSON("Expected a utf8 data")
        }
        try self.init(name: name, jsonFilters: data)
    }
    
    public init(name: String, jsonFilters: Data) throws {
        self.name = name

        guard
            let filters = try JSONSerialization.jsonObject(with: jsonFilters, options: []) as? [String: AnyObject] else {
            throw ParsingError.invalidJSON("Expected a JSON object")
        }
        // todo more validation
        self.filters = filters
    }
}

//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

public struct EventTrigger {
    let name: String
    let filters: [String: Any]

}

extension EventTrigger {
    public init(name: String, jsonFilters: Data) throws {
        self.name = name
        guard let filters = try JSONSerialization.jsonObject(with: jsonFilters, options: []) as? [String: AnyObject] else {
            throw ParsingError.invalidJSON("Expected a JSON object")
        }
        // todo more validation
        self.filters = filters
    }
}

//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import XrayKit

// MARK: - Event Requests

struct EventRequest: Encodable {
    let events: [Event]
}

// MARK: - Event Responses

struct EventStatus {
    enum Status: String {
        case success
        case failed
    }
    let uid: Int64
    let status: Status
}


// MARK: - Registration

struct XrayRegistration: Decodable {
    let deviceId: String
    let apiToken: String
}

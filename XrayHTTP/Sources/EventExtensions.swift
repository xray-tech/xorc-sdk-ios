//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import XrayKit

extension Event {
    static func pushEvent(deviceToken: String) -> Event {
        return Event(name: "xray_push_token_update", properties: ["device_token": JSONValue(deviceToken)])
    }
    static func registerEvent() -> Event {
        return Event(name: "xray_register")
    }
}

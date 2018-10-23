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

/**
 Registration data send back from the backend in response to a "register" event.
 The registration data are sent back as headers in all subsequent event requests
 */
struct XrayRegistration {
    
    /**
     Represents the id assigned to a device. If possible, this device id should be persisted in a non-volatile storage
     such as the keychain so remain the same even after app reinstal
    */
    let deviceId: String
    
    /**
     The Api token grants access to the xray platform to send any events besides the register event.
     Api tokens can be revoked, in which case the SDK needs to send a new register event
    */
    let apiToken: String
}

/**
 Intermediate structure that helps to extract the registration data from the json response:
 
 ```
 {
    "events_status": [
        {
             "id": "0",
             "status": "success",
             "registration_data": {
                "device_id": "device124",
                "api_token": "token456"
            }
        }
    ]
 }
 ```
 */
struct XrayRegistrationResponse: Decodable {
    let registrationData: XrayRegistration
    
    enum CodingKeys: String, CodingKey {
        case eventsStatus
    }
    
    init(from decoder: Decoder) throws {
        let arrayContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let dataArray = try arrayContainer.decode([XrayRegistration].self, forKey: .eventsStatus)
        
        guard let registrationData = dataArray.first else {
            let context = DecodingError.Context(codingPath: [CodingKeys.eventsStatus], debugDescription: "Expected one registration result")
            throw DecodingError.valueNotFound(XrayRegistration.self, context)
        }
        self.registrationData = registrationData
    }
}

/**
 Decodable that extracts the XrayRegistration from the following json
 
```
 {
    "id": "0",
    "status": "success",
    "registration_data": {
        "device_id": "device124",
        "api_token": ""token456""
    }
}
```
 */
extension XrayRegistration: Decodable {
    
    enum EventStatusKey: String, CodingKey {
        case eventsStatus
    }
    enum RegistrationDataKey: String, CodingKey {
        case deviceId
        case apiToken
        case registrationData
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: RegistrationDataKey.self).nestedContainer(keyedBy: RegistrationDataKey.self, forKey: .registrationData)
        
        deviceId = try values.decode(String.self, forKey: .deviceId)
        apiToken = try values.decode(String.self, forKey: .apiToken)
    }
}

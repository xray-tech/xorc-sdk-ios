//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import XrayKit


public class XrayHTTPBuilder: HTTPRequestBuilder {

    enum XrayHeaders: String {
        case apiToken   = "D360-Api-Token"
        case deviceId   = "D360-Device-Id"
        case appId      = "D360-App-Id"
        case signature  = "D360-Signature"
    }
    
    let signer: Signer
    let coder = JSONEncoder()
    
    let options: XrayCrmOptions
    var registration: XrayRegistration?
    
    init(options: XrayCrmOptions) {
        self.options = options
        self.signer = HMACSigner(apiKey: options.apiKey.dataFromHexString())
    }

    public func build(events: [Event]) throws -> URLRequest {
        var request = URLRequest(url: options.url)
        request.httpMethod = "POST"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //
        let httpBody = try coder.encode(events)
        
        request.httpBody = httpBody

        
        request.addValue(signer.sign(data: httpBody).base64EncodedString(), forHTTPHeaderField: XrayHeaders.signature.rawValue)
        
        request.addValue(options.appId, forHTTPHeaderField: XrayHeaders.appId.rawValue)
        
        if let registration = registration {
            request.addValue(registration.apiToken, forHTTPHeaderField: XrayHeaders.apiToken.rawValue)
            request.addValue(registration.deviceId, forHTTPHeaderField: XrayHeaders.deviceId.rawValue)
        }

        return request
    }
}

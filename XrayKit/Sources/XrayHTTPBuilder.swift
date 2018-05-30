//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation


public class XrayHTTPBuilder: HTTPRequestBuilder {

    enum XrayHeaders: String {
        case apiToken = "D360-Api-Token"
        case deviceId = "D360-Device-Id"
        case appId    = "D360-App-Id"
        case signature = "D360-Signature"
    }

    //let signer = D360HMACSigner(apiKey: "1aa867899db75d0967c6c77aaf5bf3d962d97fd1ffd3ee4aaae41d29dc0cee3f")
    
    public init() {
        
    }

    public func build(events: [Event]) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://staging-rt.360dialog.io/xray/events/360dialog/sdk/v1")!)
        request.httpMethod = "POST"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        
//        let data = Data()
        // todo signer
//        let hash64 = signer.sign(data)
//        request.addValue(hash64.base64EncodedString(), forHTTPHeaderField: XrayHeaders.signature.rawValue)

        return request
    }
}

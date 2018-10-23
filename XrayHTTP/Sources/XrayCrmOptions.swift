//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

public struct XrayCrmOptions {
    let appId: String
    let apiKey: String
    let url: URL
    
    public init(appId: String, apiKey: String, url: URL) {
        self.appId = appId
        self.apiKey = apiKey
        self.url = url
    }
}

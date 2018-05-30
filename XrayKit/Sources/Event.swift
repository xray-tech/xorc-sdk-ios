//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

@objc
public class Event: NSObject {

    let name: String
    let properties: [String: AnyObject]?
    
    @objc
    public init(name: String, properties: [String: AnyObject]? = nil) {
        self.name = name
        self.properties = properties
    }
}

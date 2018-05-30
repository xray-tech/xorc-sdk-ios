//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

@objc
public class Xray: NSObject {

    public static let data = DataService()
    
    public static let events = EventService()
}

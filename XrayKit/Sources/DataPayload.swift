//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

/**
 The `DataPayload` represents the data packet to be delivered to your application when needed. It contains arbitrary data relevant to you
 along with conditions when it will be delivered to your app based on triggers.
 When you hand over a `DataPayload` to the Xray SDK, it will be persisted until triggered or expired.
 */
public struct DataPayload {
    
    /// The arbitrary data to be delivered to your app
    public let data: Data
    
}

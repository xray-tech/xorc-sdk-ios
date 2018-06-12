//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

public protocol DataServiceDelegate: AnyObject {

    func dataService(_ service: DataService, didTriggerData: Data)

}

/**
 The `DataService` is the main entry for handing over the `DataPayload` to the Xray SDK.
 */
public class DataService: NSObject {

    /// The optional delegate
    public weak var delegate: DataServiceDelegate?
    
    /**
     Schedules the execution of the `DataPayload` with the given trigger and context. The `DataPayload` is persisted
     untill the execution trigger occurs.
     
     - parameter payload: The payload that you want to scheudule
     - parameter trigger: The trigger that will trigger the payload delivery
     - parameter context: Arbitrary context that will be delivered back when the payload is triggered
     
     - note: Test of a discussion
     - warning: Do not do this
    */
    public func schedule(payload: DataPayload, trigger: Any, context: Any) {

    }
}
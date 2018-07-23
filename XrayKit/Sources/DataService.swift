//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

/**
 The `DataService` is the main entry for handing over the `DataPayload` to the Xray SDK.
 */
public class DataService: NSObject {
    
    /// A block to execute when a schduled DataPayload is triggered.
    public var onTrigger: (([DataPayload]) -> Void)?
    
    /// An optional queue on which the onTrigger will be called. Default is `.main`
    public var queue: OperationQueue = .main
    
    private var controller: DataController?
    
    /**
     Schedules the execution of the `DataPayload` with the given trigger and context. The `DataPayload` is persisted
     until the execution trigger occurs.
     
     - parameter payload: The payload that you want to schedule
     - parameter trigger: The trigger that will trigger the payload delivery
     - parameter context: Arbitrary context that will be delivered back when the payload is triggered
     
     - note: Test of a discussion
     - warning: Do not do this
    */
    public func schedule(payload: DataPayload) {
        // high level verification before sending
        guard  let controller = controller else {
            print("\(#function) called before starting the SDK")
            return
        }
        
        controller.schedule(payload: payload)
        
        
    }
    
    // MARK: - Protected
    
    func start(controller: DataController) {
        self.controller = controller
        controller.onTrigger = { payload in
            self.queue.addOperation {
                self.onTrigger?(payload)
            }
        }
    }
}

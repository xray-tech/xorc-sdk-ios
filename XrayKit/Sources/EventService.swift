//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

/**
 The `EventService` is the entry point for sending events
 */
public class EventService: NSObject {

    private var controller: EventController?
    // MARK: - Public
    
    /**
     Logs an occurence of an event. The event is processed by the local rule and optionally given to an `EventTransmitter` if you registered one
     in order to be sent over the network. Logging events can result into a `DataServiceDelegate` methods to be called if this event is bound to triggers.

     - parameter event: The `Event` that has just occurred.
    */
    @objc public func log(event: Event) {
        // high level verification before sending
        guard  let controller = controller else {
            print("\(#function) called before starting the SDK")
            return
        }
        
        controller.log(event: event)
    }
    
    public func register(transmitter: EventTransmitter) {
        guard  let controller = controller else {
            print("\(#function) called before starting the SDK")
            return
        }

        controller.transmitter = transmitter
    }

    // MARK: - Protected

    func start(controller: EventController) {
        self.controller = controller
    }

}

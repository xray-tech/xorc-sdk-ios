//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

/**
 The `EventService` is the entry point for sending events
 */
public class EventService: NSObject {
    
    private var controller: EventController
    
    /// serial queue to run any public API calls on
    private let eventQueue = DispatchQueue(label: "io.xorc.events")
    
    // MARK: - Public
    
    init(controller: EventController) {
        self.controller = controller
    }
    
    
    /**
     Logs an occurrence of an event. The event is processed by the local rule and optionally given to an `EventTransmitter`
     if you registered one in order to be sent over the network.
     Logging events can result into a `DataServiceDelegate` methods to be called if this event is bound to triggers.
     
     - parameter event: The `Event` that has just occurred.
     */
    @objc public func log(event: Event) {
        eventQueue.async {
            self.controller.log(event: event)
        }
    }
    
    public func register(transmitter: EventTransmitter) {
        self.controller.transmitter = transmitter
        self.controller.transmitter?.delegate = self
        
    }
    
    // MARK: - Protected
    
    func start() {
        controller.transmitter?.start()
    }
}

extension EventService: EventTransmitterDelegate {
    
    public func eventTransmitter(_ transmitter: EventTransmitter, didChangeState state: EventTransmitterState) {
        if state == .ready {
            eventQueue.async {
                self.controller.flush()
            }
        }
    }
}

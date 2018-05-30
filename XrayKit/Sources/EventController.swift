//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

/**
 Represents the result of transmitting events.
 */
public enum EventResult {
    
    /// When the event was transmitted correctly.
    case success
    
    /// When the event failed and should be retried in the future
    case failure([Event])
}

/**
 The `EventTransmitter` defines an interface for transmitting events. The implementations responsible for serializing the `Event`s and
 transmitting them via their own protocol.
 */
public protocol EventTransmitter {
    
    /**
     This method is called internally by the Xray SDK when the event is ready to be transmitted.
     - parameter events: The `Event`s to be transmitted.
     - parameter completion: The `EventResult` complition closure telling the SDK whether the events were transmitted correctly or not.
     - warning: Do not call this method. It is meant to be called by the SDK at the right time.
    */
    func transmit(events: [Event], completion: @escaping (EventResult) -> Void)
}

class EventController {
    
    public var transmitter: EventTransmitter?
    
    public func log(event: Event) {
        
        // run event through the rule engine
        // call delegates if needed
        
        guard let transmitter = transmitter else {
            // nothing else to do. We do not persist at all
            return
        }
        
        // check for connection
        // check for app state
        // persist if needed
        // based on options: send now or batch
        transmitter.transmit(events: [event], completion: { result in
            switch result {
            case .success:
                break
            case .failure:
                break
            }
        })
    }
}

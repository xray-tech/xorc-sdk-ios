//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import XrayKit

/**
 Implementations are responsible for preparing the URL request with the given events
 The resulting request should contain everything needed to be sent.
 Implementations can define their own HTTP protocol and body formats
 */
public protocol HTTPRequestBuilder {

    /**
     Method responsible for building the request for the events that are to be sent
     - Parameter events: The events to be sent
     - Returns: The URLRequest that will be posted as is including headers
     */
    func build(events: [Event]) throws -> URLRequest
}

public class HTTPTransmitter {
    
    // todo: in the same way we inject a builder, we could inject the event Resource
    let builder: HTTPRequestBuilder
    
    let client = HTTPClient()

    public init(builder: HTTPRequestBuilder) {
        self.builder = builder
    }

    public func transmit(events: [Event], completion: @escaping ([EventResult]) -> Void) {
        print("Sending events to xray \(events)")
        
        do {
            // todo: why not passing the buider request directly to Event.post ?
            let request = try builder.build(events: events)
            
            // todo: this call exposes too much of the xray specific response.
            // what we need is a generic way to tell if a given event was successul or not
            // we could need to restrain the Ressource to response with [EventResult]
            // Implementations can use their format as long as they return the [EventResult]
            client.load(resource: EventRequest.post(request: request)) { (response) in
                
                #warning("call the actual event completion with correct results")
                
                completion(events.map { EventResult.success(event: $0) })
                
                
            }
//            URLSession.shared.dataTask(with: request) { (data, response, error) in
//                // todo response handling should probably be done somehwere else and defined as a protocol to allow flexibility
//                // todo parse response
//                // todo error, retry all
//                // todo check http error codes
//                // todo check status for each event
//            }
        } catch {
            // failed to build the request: delete events
        }

    }
}

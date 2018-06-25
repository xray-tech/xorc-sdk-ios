//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

public protocol HTTPRequestBuilder {

    func build(events: [Event]) -> URLRequest
}

public class HTTPTransmitter: EventTransmitter {
    
    var builder: HTTPRequestBuilder

    public init(builder: HTTPRequestBuilder) {
        self.builder = builder
    }

    public func transmit(events: [Event], completion: @escaping ([EventResult]) -> Void) {
        print("Sending events to xray \(events)")
        let request = builder.build(events: events)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
        }
    }
}

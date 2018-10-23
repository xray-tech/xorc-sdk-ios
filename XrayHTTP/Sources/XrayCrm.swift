//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import XrayKit


public class XrayCrm {
    
    let options: XrayCrmOptions
    let registrationController: XrayRegistrationController
    let httpTransmitter: HTTPTransmitter
    let requestBuilder: XrayHTTPBuilder
    
    public init(options: XrayCrmOptions) {
        self.options = options
        self.registrationController = XrayRegistrationController(options: options)
        
        self.requestBuilder = XrayHTTPBuilder(options: options)
        self.httpTransmitter = HTTPTransmitter(builder: self.requestBuilder)
    }
}

extension XrayCrm: EventTransmitter {
    
    public var isReady: Bool {
        return requestBuilder.registration != nil
    }
    public func transmit(events: [Event], completion: @escaping ([EventResult]) -> Void) {
        httpTransmitter.transmit(events: events, completion: completion)
    }
}

extension XrayCrm: XrayService {
    
    public func start() {
        registrationController.register { registration in
            self.requestBuilder.registration = registration
        }
    }
    
    public func dispose() {
        
    }
}

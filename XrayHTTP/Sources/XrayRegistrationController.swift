//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import XrayKit

/**
 Responsible for storing or requesting the 1st "registration" event to obtain the
 Device-Id and Api-Token that will be sent as headers on all subsequent events
 */
class XrayRegistrationController {
    
    private let options: XrayCrmOptions
    private let client = HTTPClient()
    private var registration: XrayRegistration?
    
    init(options: XrayCrmOptions) {
      self.options = options
    }
    
    func register(completion: (XrayRegistration) -> Void) {
        // get from store or fetch new
        if let registration = registration {
            completion(registration)
            return
        }
        
        sendRegister {
            //completion(
        }
        
    }
    
    /// Sends the registration
    
    private func sendRegister(completion: () -> Void) {
        let builder = XrayHTTPBuilder(options: options)
        
        let registerEvent = Event(name: "d360_register")
        guard let request = try? builder.build(events: [registerEvent]) else { fatalError("registration event should cound not be built") }
        
        let resource = XrayRegistration.post(request: request)
        client.load(resource: resource) { (response) in
            switch response {
            case .success(let registration):
                print("Registration result: \(registration)")
                // store the registration
                self.registration = registration
                // call delegates to propagate registration until the event emitter

            case .error(let error):
                print("Registration error: \(error)")
            }
        }
    }
}

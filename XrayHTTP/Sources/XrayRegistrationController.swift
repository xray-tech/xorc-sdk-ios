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
    
    init(options: XrayCrmOptions) {
        self.options = options
    }
    
    func register(completion: @escaping (Registration) -> Void) {
        // get from store or fetch new
        
        if KeyValueStore.shared().appInstanceId == nil {
            KeyValueStore.shared().appInstanceId = UUID().uuidString
        }
        if let registration = KeyValueStore.shared().registration {
            completion(registration)
            return
        }
        
        sendRegister { registration in
            print("######## New Registration result: \(registration.deviceId)")
            KeyValueStore.shared().registration = registration
            completion(registration)
        }
    }
    
    /// Sends the registration
    
    private func sendRegister(completion: @escaping (Registration) -> Void) {
        let builder = XrayHTTPBuilder(options: options)
        
        let registerEvent = Event.registerEvent()
        guard let request = try? builder.build(events: [registerEvent]) else { fatalError("registration event should cound not be built") }
        
        let resource = Registration.post(request: request)
        client.load(resource: resource) { (response) in
            switch response {
            case .success(let registration):
                completion(registration)
            case .error(let error):
                print("Registration error: \(error)")
            }
        }
    }
}

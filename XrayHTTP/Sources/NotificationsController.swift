//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import XrayKit

public class NotificationService {
    
    // MARK: - Public
    public func registerDeviceToken(deviceToken: Data) {
        let deviceTokenString = deviceToken.hexEncodedString()
        print("""
            ##################################### SDK push token #################################################
            \(deviceTokenString))
            ######################################################################################################
        """)
        
        Xray.events.log(event: Event.pushEvent(deviceToken: deviceTokenString))
    }
    
    // MARK: - Protected
    func start() {
        registerForRemoteNotifications()
    }
    
    // MARK: - Private
    private func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
}

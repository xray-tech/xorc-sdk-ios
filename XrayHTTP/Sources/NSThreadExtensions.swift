//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

extension Thread {
    
    static func onMain(block: () -> Void) {
        if isMainThread {
            block()
        } else {
            DispatchQueue.main.sync { block() }
        }
    }
}

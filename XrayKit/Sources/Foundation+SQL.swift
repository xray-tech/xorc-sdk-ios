//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

extension Date {
    
    func toSql() -> NSNumber {
        return self.timeIntervalSince1970 as NSNumber
    }
}

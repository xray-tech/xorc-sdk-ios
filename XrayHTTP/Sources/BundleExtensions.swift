//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

extension Bundle {
    var version: String {
        guard let infos = infoDictionary else { return "" }
        return (infos["CFBundleShortVersionString"] as? String ?? "")
    }
    
    var build: String {
        guard let infos = infoDictionary else { return "" }
        return (infos["CFBundleVersion"] as? String ?? "")
    }
}

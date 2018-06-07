//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

class SQLRequest {
    
    let sql: String
    
    init(sql: String) {
        self.sql = sql
    }
    func build() -> String {
        return sql
    }
}

class SQLResponse {
    
}

//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

class SQLDatabaseController: EventStore {

    private let connection: Connection
    
    /// queue that ensures that all requests to the DB are made in a serial order
    private let queue = DispatchQueue(label: "io.xorc")

    init(connection: Connection) {
        self.connection = connection
    }
    
    // MARK: - Private

    func insert<Element: Insertable>(element: Element) -> Element {
        var element = element
        
        let request = SQLRequest(insertInto: type(of: element).tableName, binds: element.binds)
        
        let insertId: Int64? = queue.sync {
            do {
                let result = try self.connection.execute(request: request)
                return result.insertId
            } catch let error {
                print("SQL request failed: \(error)")
            }
            return nil
        }
        
        element.sequenceId = insertId ?? 0
        return element
    }
}

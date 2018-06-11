//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

class SQLDatabaseController: EventStore {

    private let connection: SQLConnection
    
    /// queue that ensures that all requests to the DB are made in a serial order
    private let queue = DispatchQueue(label: "io.xorc")

    init(connection: SQLConnection) {
        self.connection = connection
    }

    // MARK: - EventStore

    func insert(event: Event) -> Event {

        let request = SQLRequest(insertInto: type(of: event).tableName, binds: event.binds)

        queue.sync {
            do {
                let result = try self.connection.execute(request: request)
                if let insertId = result.insertId {
                    event.sequenceId = insertId
                }
            } catch let error {
                print("SQL request failed: \(error)")
            }
        }
        return event
    }
    
    // MARK: - Private
}

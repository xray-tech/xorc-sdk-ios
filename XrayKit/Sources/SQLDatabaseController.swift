//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

class SQLDatabaseController {

    private let connection: Connection
    
    /// queue that ensures that all requests to the DB are made in a serial order
    private let queue = DispatchQueue(label: "io.xorc")

    init(connection: Connection) {
        self.connection = connection
    }
    
    // MARK: - Private

    func insert<Entry: Insertable>(entry: Entry) -> Entry {
        var entry = entry
        
        let insertId: Int64? = queue.sync {
            do {
                return try self.connection.execute(request: entry.insertRequest).insertId
            } catch let error {
                print("SQL request failed: \(error)")
            }
            return nil
        }
        
        entry.sequenceId = insertId ?? 0
        return entry
    }
    
    
    func select<Entry: Deserializable> (where: String) -> [Entry] {
        
        let request = SQLRequest(selectFrom: EventTable.tableName)
        
        var entries = [Entry]()
        queue.sync {
            do {
                let result = try self.connection.execute(request: request)
                guard let resultSet = result.resultSet else { return }
                
                for resultSet in resultSet {
                    if let entity = try? Entry.deserialize(resultSet) {
                        entries.append(entity)
                    }
                }
            } catch {
              print("SQL request failed: \(error)")
            }
        }
        return entries
    }

    func update() {
        
    }
}

extension SQLDatabaseController: EventStore {
    
    func select(priority: Event.Priority, nextTryAt: Date, batchMaxSize: Int) {

    }
}

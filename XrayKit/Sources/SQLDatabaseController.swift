//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

class SQLDatabaseController {

    private let connection: Connection
    
    /// queue that ensures that all requests to the DB are made in a serial order
    private let queue = DispatchQueue(label: "io.xorc")

    init(connection: Connection, tables: [Table.Type]) {
        self.connection = connection
        
        for table in tables {
            try? connection.execute(request: table.createRequest)
        }
    }
    
    // MARK: - Private

    func insert<Entry: Insertable>(entry: Entry) -> Entry {
        var entry = entry
        
        let insertId: Int64? = queue.sync {
            do {
                return try self.connection.execute(request: entry.insertRequest).insertId
            } catch let error {
                print("\(#function) failed: \(error)")
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
                print("\(#function) failed: \(error)")
            }
        }
        return entries
    }

    func update<Entry: Updatable>(entry: Entry) {
        var entry = entry
        queue.sync {
            do {
                // todo return updated entries?
                let _ = try self.connection.execute(request: entry.updateRequest())
            } catch {
                print("\(#function) failed: \(error)")
            }
        }
    }
}

extension SQLDatabaseController: EventStore {
    func insert(event: Event) -> Event {
        return insert(entry: event)
    }

    func select(priority: Event.Priority, nextTryAt: Date, batchMaxSize: Int) {

    }
}

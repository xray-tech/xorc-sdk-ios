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
        
        let insertId: Int64? = queue.sync {
            do {
                return try self.connection.execute(request: element.insertRequest).insertId
            } catch let error {
                print("SQL request failed: \(error)")
            }
            return nil
        }
        
        element.sequenceId = insertId ?? 0
        return element
    }
    
    
    func select<Element: Deserializable> (where: String) -> [Element] {
        
        let request = SQLRequest(selectFrom: EventTable.tableName)
        
        var entities = [Element]()
        queue.sync {
            do {
                let result = try self.connection.execute(request: request)
                guard let resultSet = result.resultSet else { return }
                
                for resultSet in resultSet {
                    if let entity = try? Element.deserialize(resultSet) {
                        entities.append(entity)
                    }
                }
            } catch {
              print("SQL request failed: \(error)")
            }
        }
        return entities
    }
}

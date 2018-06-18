//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

@objc
public class Xray: NSObject {

    public static let data = DataService()
    
    public static let events = EventService()

    // MARK: - Private

    let eventController: EventController


    override init() {
        let connection = SQLConnection(path: FileManager.databaseFilePath())
        let store = SQLDatabaseController(connection: connection, tables: [EventTable.self])
        self.eventController = EventController(eventStore: store)

    }
}

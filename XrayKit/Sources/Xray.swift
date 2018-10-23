//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

@objc
public class Xray: NSObject {

    public static var data: DataService {
        return instance.data
    }
    
    public static var events: EventService {
        return instance.events
    }

    // MARK: - Private

    private static let instance = Xray()
    
    private lazy var events = EventService(controller: eventController)
    private lazy var data = DataService(controller: dataController)

    private lazy var connection = SQLConnection(path: FileManager.databaseFilePath())
    private lazy var store = SQLDatabaseController(connection: connection, tables: [EventTable.self, DataTable.self])
    
    private lazy var eventController = EventController(eventStore: store)
    private lazy var dataController = DataController(store: store)

    override private init() {
        
    }
    
    private func start(options: Any?) {
        events.start()
        data.start()
    }
    
    // MARK: - Public
    public static func start(options: Any? = nil) {
        instance.start(options: options)
    }
}

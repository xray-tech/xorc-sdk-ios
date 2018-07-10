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
    
    private let events = EventService()
    private let data = DataService()
    
    private static let instance = Xray()
    
    public static var events: EventService {
        return instance.events
    }

    // MARK: - Private

    let eventController: EventController
    let dataController: DataController


    override init() {
        let connection = SQLConnection(path: FileManager.databaseFilePath())
        let store = SQLDatabaseController(connection: connection, tables: [EventTable.self, DataTable.self])
        
        eventController = EventController(eventStore: store)
        dataController = DataController(store: store)
        
        eventController.onEvent = dataController.trackEvent
    }
    
    private func start(options: Any?) {
        events.start(controller: eventController)
        data.start(controller: dataController)
    }
    
    // MARK: - Public
    public static func start(options: Any? = nil) {
        instance.start(options: options)
    }
}

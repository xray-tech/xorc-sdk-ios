//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

@objc
public class Xray: NSObject {

    public static let data = DataService()
    
    private let events = EventService()
    
    private static let instance = Xray()
    
    public static var events: EventService {
        return instance.events
    }

    // MARK: - Private

    let eventController: EventController


    override init() {
        let connection = SQLConnection(path: FileManager.databaseFilePath())
        let store = SQLDatabaseController(connection: connection, tables: [EventTable.self])
        self.eventController = EventController(eventStore: store)
    }
    
    private func start(options: Any?) {
        events.start(controller: eventController)
    }
    
    // MARK: - Public
    public static func start(options: Any? = nil) {
        instance.start(options: options)
    }
}

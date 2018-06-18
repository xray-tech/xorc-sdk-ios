//: Playground - noun: a place where people can play

//import UIKit
import Foundation
import PlaygroundSupport

@testable import XrayKit

var str = "Hello, playground"

let path = playgroundSharedDataDirectory.appendingPathComponent("SQLiteTutorial").resolvingSymlinksInPath().appendingPathComponent("db.sqlite")

try? FileManager.default.removeItem(at: path)


let store = SQLDatabaseController(connection: SQLConnection(path: path.absoluteString), tables: [EventTable.self])

let eventController = EventController(eventStore: store)

eventController.transmitter = PlaygroundTransmitter()

eventController.log(event: Event(name: "my_event", properties: ["foo": "bar"]))

//: Playground - noun: a place where people can play

//import UIKit
import Foundation
import PlaygroundSupport
@testable import XrayKit

var str = "Hello, playground"

let path = playgroundSharedDataDirectory.appendingPathComponent("SQLiteTutorial").resolvingSymlinksInPath().appendingPathComponent("db.sqlite")

let connection = SQLConnection(path: path.absoluteString)
let table = EventTable()

//do {
    try? connection.execute(request: table.createRequest)
//} catch let error {
//    print(error)
//}

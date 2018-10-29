//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation


func JSONObjectForFile(fileName: String, aClass: AnyClass) -> [String: Any] {
    return JSONForFile(fileName: fileName, aClass: aClass)
}

func JSONArrayForFile(fileName: String, aClass: AnyClass) -> [Any] {
    return JSONForFile(fileName: fileName, aClass: aClass)
}
func JSONForFile<T>(fileName: String, aClass: AnyClass) -> T {

    let bundle = Bundle(for: aClass)
    guard let path = bundle.url(forResource: fileName, withExtension: nil) else {
        fatalError("Unit test resource '\(fileName)' does not exist")
    }

    do {
        let data = try Data(contentsOf: path)
        let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)

        guard let jsonTyped = json as? T else {
            fatalError()
        }

        return jsonTyped
    } catch {
        fatalError("Could not read unit test file '\(fileName)': \(error)")
    }
}
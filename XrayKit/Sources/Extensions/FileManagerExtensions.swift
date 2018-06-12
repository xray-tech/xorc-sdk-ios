//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation


extension FileManager {

    private static let xrayDirectoryBaseName = "io.xray"
    private static let xrayDBName = "xray.sqlite"

    /**
        Creates and returns the Application Support directory used for any SDK storage
    */
    static func applicationSupportDirectory() -> String {

        guard var baseStoragePath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last else {
            print("Could not get support Application Support directory. Using tmp as default storage")
            return NSTemporaryDirectory()
        }

        baseStoragePath.append(xrayDirectoryBaseName)
        do {
            try FileManager.default.createDirectory(atPath: baseStoragePath, withIntermediateDirectories: true)
        } catch {
            print("Could not create base directory in Application Support: \(error)")
            baseStoragePath = NSTemporaryDirectory()
        }
        return baseStoragePath
    }

    static func databaseFilePath() -> String {
        let applicationSupport = applicationSupportDirectory()
        return (applicationSupport as NSString).appendingPathComponent(xrayDBName)

    }
}
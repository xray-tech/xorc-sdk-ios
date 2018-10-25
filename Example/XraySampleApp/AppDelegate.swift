//
//  AppDelegate.swift
//  XraySampleApp
//
//  Created by Jan Chaloupecky on 30.05.18.
//  Copyright © 2018 360dialog. All rights reserved.
//

import UIKit
import XrayKit
import XrayHTTP
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var crm: XrayCrm!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let urlString = "https://staging-rt.360dialog.io/xray/events/360dialog/sdk/v1"
//        let urlString = "http://localhost:8080/events/"
        
        let url = URL(string: urlString)!
        let options = XrayCrmOptions(appId: "36", apiKey: "1aa867899db75d0967c6c77aaf5bf3d962d97fd1ffd3ee4aaae41d29dc0cee3f", url: url)
        
        crm = XrayCrm(options: options)
        
        Xray.events.register(transmitter: crm)
        
        Xray.events.log(event: Event(name: "before_start"))
        
    
        Xray.start()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        crm.push.registerDeviceToken(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to get push token: \(error)")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

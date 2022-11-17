//
//  TEXGridApp.swift
//  TEXGrid
//
//  Created by Greg Whatley on 7/13/22.
//

import SwiftUI
import BackgroundTasks

fileprivate let REQUEST_ID = "TEXGridDataRefresh"
fileprivate let SESSION_ID = "TEXGridDataURLSession"

extension BackgroundTasks {
    static func registerBackgroundTask() {
        if BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundTasks.requestIdentifier, using: .main, launchHandler: { task in
            BackgroundTasks.handle(task, withCompletion: nil)
        }) {
            print("Task registration completed")
        } else {
            print("Task registration failed")
        }
    }
}

@main
struct TEXGridApp: App {
    @UIApplicationDelegateAdaptor(TEXGridAppDelegate.self) private var appDelegate
    //@Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class TEXGridAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge], completionHandler: {success, error in })
        BackgroundTasks.registerBackgroundTask()
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        BackgroundTasks.Session.shared.completionHandler = completionHandler
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .list]
    }
}

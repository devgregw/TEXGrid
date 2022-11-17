//
//  BackgroundTasks.swift
//  TEXGrid
//
//  Created by Greg Whatley on 8/14/22.
//

import Foundation
import BackgroundTasks
import UserNotifications

class BackgroundTasks {
    class Session: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
        static let identifier = "TEXGridDataURLSession"
        static let shared = Session()
        
        private var session: URLSession!
        private var backgroundTask: BGTask?
        
        private override init() {
            super.init()
            let configuration = URLSessionConfiguration.background(withIdentifier: Session.identifier)
            configuration.sessionSendsLaunchEvents = true
            session = .init(configuration: configuration, delegate: self, delegateQueue: nil)
        }
        
        func cancelAllTasks() {
            session.getAllTasks(completionHandler: {tasks in
                tasks.forEach { $0.cancel() }
            })
        }
        
        func data(for url: String, dueTo backgroundTask: BGTask?, customCompletion: (() -> Void)?, cachePolicy: URLRequest.CachePolicy = .reloadIgnoringCacheData) {
            self.backgroundTask = backgroundTask
            if customCompletion != nil {completionHandler = customCompletion}
            let task = session.dataTask(with: .init(url: .init(string: url)!, cachePolicy: cachePolicy, timeoutInterval: 20))
            requests[task.currentRequest!.url!.lastPathComponent] = false
            task.resume()
        }
        
        #if !os(macOS)
        internal var completionHandler: (() -> Void)?
        
        func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
            DispatchQueue.main.async { [self] in
                print("Calling completion handlers")
                completionHandler?()
                completionHandler = nil
            }
        }
        #endif
        
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            let taskName = task.currentRequest!.url!.lastPathComponent
            print("Task completed: \(taskName)")
            requests[taskName] = true
            if let error = error {
                print(error.localizedDescription)
                UserDefaults.standard.removeObject(forKey: taskName)
            } else {
                if let completeData = getData(forTask: task) {
                    let s = String(data: completeData, encoding: .utf8)
                    UserDefaults.standard.set(s, forKey: taskName)
                } else {
                    UserDefaults.standard.removeObject(forKey: taskName)
                }
                
            }
            
            if requests.count == completeData.count && requests.keys.allSatisfy({key in completeData.keys.contains(key)}) && requests.values.allSatisfy({$0}) {
                print("All URLSession tasks complete")
                UserDefaults.standard.synchronize()
                completeData.removeAll()
                requests.removeAll()
                urlSessionDidFinishEvents(forBackgroundURLSession: session)
                backgroundTask?.setTaskCompleted(success: true)
            }
        }
        
        private var completeData: [String: Data] = [:]
        private var requests: [String: Bool] = [:]
        
        private func getData(forTask dataTask: URLSessionTask) -> Data? {
            return completeData[dataTask.currentRequest!.url!.lastPathComponent]
        }
        
        private func build(_ data: Data, forTask dataTask: URLSessionTask) -> Bool {
            var newData: Data = data
            var isNew = true
            if var currentData = getData(forTask: dataTask) {
                currentData.append(data)
                newData = currentData
                isNew = false
            }
            completeData[dataTask.currentRequest!.url!.lastPathComponent] = newData
            return isNew
        }
        
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            if build(data, forTask: dataTask) {
                print("Task started: \(dataTask.currentRequest?.url?.lastPathComponent ?? "nil")")
            }
        }
    }
    
    static let requestIdentifier = "TEXGridDataRefresh"
    static let taskRunInterval: DateComponents? = nil
    
    static func loadDataImmediately() async {
        await withCheckedContinuation { continuation in
            handle(nil, withCompletion: {
                continuation.resume(returning: ())
            })
        }
    }
    
    static func handle(_ bgTask: BGTask?, withCompletion customCompletion: (() -> Void)?) {
        if let bgTask = bgTask {
            print("Handling task")
            scheduleTask()
            bgTask.expirationHandler = {Session.shared.cancelAllTasks()}
        }
        Session.shared.data(for: "https://www.ercot.com/api/1/services/read/dashboards/daily-prc.json", dueTo: bgTask, customCompletion: customCompletion)
        Session.shared.data(for: "https://www.ercot.com/api/1/services/read/dashboards/todays-outlook.json", dueTo: bgTask, customCompletion: customCompletion)
        Session.shared.data(for: "https://www.ercot.com/api/1/services/read/dashboards/combine-wind-solar.json", dueTo: bgTask, customCompletion: customCompletion)
    }
    
    static func simulateTaskInvocation() {
#if DEBUG
        var count: UInt32 = 0
        let methods = class_copyMethodList(BGTaskScheduler.self, &count)!
        for i in 0..<Int(count) {
            let methodName = String(cString: sel_getName(method_getName(methods[i])), encoding: .utf8)!
            if methodName == "_simulateLaunchForTaskWithIdentifier:" {
                if let selector = method_getDescription(methods[i]).pointee.name {
                    BGTaskScheduler.shared.perform(selector, with: requestIdentifier)
                }
                break
            }
        }
#else
        print("Cannot simulate task")
#endif
    }
    
    static func scheduleTask() {
        let request = BGAppRefreshTaskRequest(identifier: requestIdentifier)
        request.earliestBeginDate = taskRunInterval == nil ? nil : Calendar.current.date(byAdding: taskRunInterval!, to: .now)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduled with earliest begin date: \(request.earliestBeginDate?.formatted() ?? "now")")
        } catch {
            print("Failed to schedule with error: \(error.localizedDescription)")
            print("Unavailable: \(BGTaskScheduler.Error.unavailable), not permitted: \(BGTaskScheduler.Error.notPermitted), too many: \(BGTaskScheduler.Error.tooManyPendingTaskRequests)")
        }
    }
}

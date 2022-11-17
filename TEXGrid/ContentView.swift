//
//  ContentView.swift
//  TEXGrid
//
//  Created by Greg Whatley on 7/13/22.
//

import SwiftUI
import Charts
import BackgroundTasks

#if DEBUG
struct DebugToolsView: View {
    @State var debugAlert: Bool = false
    @State var debugAlertText: String = ""
    
    var body: some View {
        Section("Tools") {
            Button("Cancel tasks") {
                BGTaskScheduler.shared.cancelAllTaskRequests()
                debugAlert = true
                debugAlertText = "All tasks cancelled"
            }
            Button("Print tasks to log") {
                BGTaskScheduler.shared.getPendingTaskRequests(completionHandler: {tasks in
                    tasks.forEach {task in
                        print(task.description)
                    }
                })
            }
            Button("Schedule task") {
                BackgroundTasks.scheduleTask()
                debugAlert = true
                debugAlertText = "Task scheduled"
            }
            Button("Simulate task run") {
                BackgroundTasks.simulateTaskInvocation()
                debugAlert = true
                debugAlertText = "Simulation started"
            }
        }
        .alert("Alert", isPresented: $debugAlert, actions: {Button("Dismiss") {debugAlert = false}}, message: {Text(debugAlertText)})
    }
}
#endif

struct ContentView: View {
    private let isPreviewContext: Bool
    @StateObject private var texGrid: TEXGridData = .init(loadNow: false)
    
    init(isPreviewContext: Bool = false) {
        self.isPreviewContext = isPreviewContext
    }
    
    var body: some View {
        NavigationView {
            List {
                #if DEBUG
                DebugToolsView()
                #endif
                Section("Operating Reserves", content: {
                    if let os = texGrid.operatingReserves {
                        OperatingReservesChart(operatingReserves: os)
                    } else {
                        ProgressView()
                    }
                })
                Section("Charts") {
                    NavigationLink(destination: {
                        if let to = texGrid.todaysOutlook {
                            TodaysOutlookChart(todaysOutlook: to)
                        } else {
                            ProgressView()
                        }
                    }, label: {Text("Today's Outlook")})
                    NavigationLink(destination: {
                        if let ws = texGrid.windSolar {
                            WindSolarChart(windSolar: ws)
                        } else {
                            ProgressView()
                        }
                    }, label: {Text("Wind & Solar")})
                }
            }
            .refreshable {
                guard !isPreviewContext else {return}
                await texGrid.refresh(fromDefaults: false)
            }
            .task {
                if isPreviewContext {
                    texGrid.usePreviewData()
                } else {
                    await texGrid.refresh(fromDefaults: true)
                }
            }
            .navigationTitle("TEXGrid")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isPreviewContext: true)
    }
}

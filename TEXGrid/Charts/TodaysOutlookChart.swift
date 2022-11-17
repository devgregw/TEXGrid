//
//  TodaysOutlookChart.swift
//  TEXGrid
//
//  Created by Greg Whatley on 8/16/22.
//

import Foundation
import SwiftUI
import Charts

struct TodaysOutlookChart: View {
    
    //@ObservedObject var texGrid: TEXGridData
    let todaysOutlook: TodaysOutlook
    
    var body: some View {
        Chart {
            ForEach(todaysOutlook.forecatedCapacity) {point in
                LineMark(x: .value("Time", point.x), y: .value("Value", point.y), series: .value("Series", "Capacity (forecasted)"))
                    .foregroundStyle(by: .value("Series", "Capacity (forecasted)"))
                    .lineStyle(by: .value("Series", "Capacity (forecasted)"))
            }
            ForEach(todaysOutlook.actualCapacity) {point in
                LineMark(x: .value("Time", point.x), y: .value("Value", point.y), series: .value("Series", "Capacity (actual)"))
                    .foregroundStyle(by: .value("Series", "Capacity (actual)"))
                    .lineStyle(by: .value("Series", "Capacity (actual)"))
            }
            ForEach(todaysOutlook.forecastedDemand) {point in
                LineMark(x: .value("Time", point.x), y: .value("Value", point.y), series: .value("Series", "Demand (forecasted)"))
                    .foregroundStyle(by: .value("Series", "Demand (forecasted)"))
                    .lineStyle(by: .value("Series", "Demand (forecasted)"))
            }
            ForEach(todaysOutlook.actualDemand) {point in
                LineMark(x: .value("Time", point.x), y: .value("Value", point.y), series: .value("Series", "Demand (actual)"))
                    .foregroundStyle(by: .value("Series", "Demand (actual)"))
                    .lineStyle(by: .value("Series", "Demand (actual)"))
            }
            /*RuleMark(x: .value("Now", todaysOutlook.updated))
                .foregroundStyle(.gray.opacity(0.75))
                .lineStyle(.init(lineWidth: 2, lineCap: .round, dash: [5.0, 5.0]))*/
        }
        .chartXScale(domain: Calendar.current.startOfDay(for: todaysOutlook.updated)...Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: todaysOutlook.updated)!)
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour)) {value in
                let hour = value.as(Date.self)!.hour
                if hour % 2 == 0 {
                    AxisGridLine()
                }
                if (hour - 4) % 4 == 0 {
                    AxisTick()
                    AxisValueLabel(format: .dateTime.hour())
                        .font(.system(size: 9.0))
                }
            }
        }
        .chartYAxisLabel(content: {Text("GW")})
        .chartXAxisLabel(content: {Text("Time")})
        .chartForegroundStyleScale([
            "Capacity (actual)": .green,
            "Capacity (forecasted)": .green.opacity(0.75),
            "Demand (actual)": .blue,
            "Demand (forecasted)": .blue.opacity(0.75)
        ])
        .chartLineStyleScale([
            "Capacity (actual)": StrokeStyle(lineWidth: 2),
            "Capacity (forecasted)": StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5.0]),
            "Demand (actual)": StrokeStyle(lineWidth: 2),
            "Demand (forecasted)": StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5.0])
        ])
        .frame(height: 250)
    }
}

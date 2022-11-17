//
//  WindSolarChart.swift
//  TEXGrid
//
//  Created by Greg Whatley on 8/16/22.
//

import Foundation
import SwiftUI
import Charts

struct WindSolarChart: View {
    let windSolar: WindSolar
    
    var body: some View {
        Chart {
            ForEach(windSolar.today.windPoints) {point in
                LineMark(x: .value("Hour", point.x), y: .value("Wind Gen", point.y), series: .value("Series", "Wind (actual)"))
                    .foregroundStyle(by: .value("Series", "Wind (actual)"))
                    .lineStyle(by: .value("Series", "Wind (actual)"))
                    .interpolationMethod(.linear)
            }
            ForEach(windSolar.today.solarPoints) {point in
                LineMark(x: .value("Hour", point.x), y: .value("Solar Gen", point.y), series: .value("Series", "Solar (actual)"))
                    .foregroundStyle(by: .value("Series", "Solar (actual)"))
                    .lineStyle(by: .value("Series", "Solar (actual)"))
                    .interpolationMethod(.linear)
            }
            ForEach(windSolar.today.combinedPoints) {point in
                LineMark(x: .value("Hour", point.x), y: .value("Combined Gen", point.y), series: .value("Series", "Combined (actual)"))
                    .foregroundStyle(by: .value("Series", "Combined (actual)"))
                    .lineStyle(by: .value("Series", "Combined (actual)"))
                    .interpolationMethod(.linear)
            }
            ForEach(windSolar.today.forecastedWindPoints) {point in
                LineMark(x: .value("Hour", point.x), y: .value("Forecasted Wind Gen", point.y), series: .value("Series", "Wind (forecasted)"))
                    .foregroundStyle(by: .value("Series", "Wind (forecasted)"))
                    .lineStyle(by: .value("Series", "Wind (forecasted)"))
                    .interpolationMethod(.linear)
            }
            ForEach(windSolar.today.forecastedSolarPoints) {point in
                LineMark(x: .value("Hour", point.x), y: .value("Forecasted Solar Gen", point.y), series: .value("Series", "Solar (forecasted)"))
                    .foregroundStyle(by: .value("Series", "Solar (forecasted)"))
                    .lineStyle(by: .value("Series", "Solar (forecasted)"))
                    .interpolationMethod(.linear)
            }
            ForEach(windSolar.today.forecastedCombinedPoints) {point in
                LineMark(x: .value("Hour", point.x), y: .value("Forecasted Combined Gen", point.y), series: .value("Series", "Combined (forecasted)"))
                    .foregroundStyle(by: .value("Series", "Combined (forecasted)"))
                    .lineStyle(by: .value("Series", "Combined (forecasted)"))
                    .interpolationMethod(.linear)
            }
        }
        .chartXScale(domain: Calendar.current.startOfDay(for: windSolar.updated)...Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: windSolar.updated)!)
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
        .chartForegroundStyleScale([
            "Wind (actual)": .blue,
            "Wind (forecasted)": .blue.opacity(0.75),
            "Solar (actual)": .green,
            "Solar (forecasted)": .green.opacity(0.75),
            "Combined (actual)": .orange,
            "Combined (forecasted)": .orange.opacity(0.75)
        ])
        .chartLineStyleScale([
            "Wind (actual)": StrokeStyle(lineWidth: 2, lineCap: .round),
            "Wind (forecasted)": StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5.0]),
            "Solar (actual)": StrokeStyle(lineWidth: 2, lineCap: .round),
            "Solar (forecasted)": StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5.0]),
            "Combined (actual)": StrokeStyle(lineWidth: 2, lineCap: .round),
            "Combined (forecasted)": StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5.0])
        ])
        .chartYAxisLabel(content: {Text("GW")})
        .chartXAxisLabel(content: {Text("Time")})
        .frame(height: 250)
    }
}

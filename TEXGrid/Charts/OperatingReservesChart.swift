//
//  OperatingReservesChart.swift
//  TEXGrid
//
//  Created by Greg Whatley on 8/16/22.
//

import Foundation
import SwiftUI
import Charts

struct OperatingReservesChart: View {
    let configurations: [OperatingReserves.GridCondition: (image: String, label: String, background: Color?, foreground: Color?)] = [
        .normal: ("checkmark", "Normal", .green, .white),
        .conserve: ("bolt.slash.fill", "Conserve", .yellow, .black),
        .emergency1: ("exclamationmark.triangle.fill", "Emergency", .orange, .white),
        .emergency2: ("exclamationmark.2", "Emergency", .red, .white),
        .emergency3: ("exclamationmark.octagon.fill", "Critical", .init(white: 0.1), .white),
        .unknown: ("questionmark", "Unknown", nil, nil)
    ]
    
    //@ObservedObject var texGrid: TEXGridData
    let operatingReserves: OperatingReserves
    
    var body: some View {
        VStack {
            Chart(operatingReserves.data) {
                    LineMark(x: .value("Time", $0.x), y: .value("Reserves", $0.y))
                        .foregroundStyle(.foreground)
                        .interpolationMethod(.linear)
                }
            .chartXScale(domain: Calendar.current.startOfDay(for: operatingReserves.updated)...Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: operatingReserves.updated)!)
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
            .chartXAxisLabel(content: {Text("Time")})
            .chartYAxisLabel(content: {Text("GW")})
            .frame(height: 250)
            
            Gauge(value: Double(operatingReserves.current.gridCondition.intValue), in: 1...5, label: {Text("")}, currentValueLabel: {Image(systemName: configurations[operatingReserves.current.gridCondition]!.image)})
                .gaugeStyle(.accessoryCircular)
                .tint(Gradient(colors: [.green, .yellow, .orange, .red, .init(white: 0.1)]))
            
            HStack {
                Text(operatingReserves.current.value, format: .number)
                Text("MW")
            }
            .font(.title)
            Text(operatingReserves.current.note)
                .font(.footnote)
                .multilineTextAlignment(.center)
            Text(operatingReserves.updated.formatted())
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

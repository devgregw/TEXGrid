//
//  TEXGridWidget.swift
//  TEXGridWidget
//
//  Created by Greg Whatley on 7/18/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TEXGridEntry {
        TEXGridEntry(date: Date(), state: .normal, context: context)
    }

    func getSnapshot(in context: Context, completion: @escaping (TEXGridEntry) -> ()) {
        guard !context.isPreview else {
            completion(TEXGridEntry(date: Date(), state: .normal, context: context))
            return
        }
        
        TEXGridData.getCurrentGridCondition(completion: { updated, state in
            completion(TEXGridEntry(date: updated, state: state, context: context))
        })
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context, completion: {entry in
            completion(Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .minute, value: 30, to: Date())!)))
        })
    }
}

struct TEXGridEntry: TimelineEntry {
    let date: Date
    let state: OperatingReserves.GridCondition
    let context: (family: WidgetFamily, isPreview: Bool)
    
    init(date: Date, state: OperatingReserves.GridCondition, family: WidgetFamily, isPreview: Bool) {
        self.date = date
        self.state = state
        self.context = (family, isPreview)
    }
    
    init(date: Date, state: OperatingReserves.GridCondition, context: TimelineProviderContext) {
        self.init(date: date, state: state, family: context.family, isPreview: context.isPreview)
    }
}

struct TEXGridWidgetEntryView : View {
    var entry: Provider.Entry

    let configurations: [OperatingReserves.GridCondition: (image: String, label: String, background: Color?, foreground: Color?)] = [
        .normal: ("checkmark", "Normal", .green, .white),
        .conserve: ("bolt.slash.fill", "Conserve", .yellow, .black),
        .emergency1: ("exclamationmark.triangle.fill", "Emergency", .orange, .white),
        .emergency2: ("exclamationmark.2", "Emergency", .red, .white),
        .emergency3: ("exclamationmark.octagon.fill", "Critical", .init(white: 0.1), .white),
        .unknown: ("questionmark", "Unknown", nil, nil)
    ]
    
    var image: some View {
        Image(systemName: configurations[entry.state]!.image)
    }
    
    var label: some View {
        return VStack {
            basicLabel
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(configurations[entry.state]!.background ?? .init(uiColor: .systemBackground))
                .foregroundColor(configurations[entry.state]!.foreground ?? .primary)
        }
        .cornerRadius(10, antialiased: true)
    }
    
    var basicLabel: some View {
        Text(configurations[entry.state]!.label)
            .multilineTextAlignment(.center)
            .lineLimit(1)
    }
    
    var gauge: some View {
        Gauge(value: Double(entry.state.intValue), in: 1...5, label: {Text("Grid")}, currentValueLabel: {image})
        .gaugeStyle(.accessoryCircular)
        .tint(Gradient(colors: [.green, .yellow, .orange, .red, .init(white: 0.1)]))
    }
    
    var body: some View {
        switch entry.context.family {
        case .systemSmall:
            return AnyView(VStack {
                gauge
                label
                Text(entry.date.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
            }
            .padding())
            
        case .accessoryCircular: return AnyView(gauge)
        case .accessoryInline: return AnyView(HStack {
            image
            basicLabel
        })
        default: return AnyView(EmptyView())
        }
    }
}

@main
struct TEXGridWidget: Widget {
    let kind: String = "TEXGridWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TEXGridWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Grid Conditions")
        .description("Displays the current power grid status.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryInline])
    }
}

struct TEXGridWidget_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([WidgetFamily.systemSmall, .accessoryInline, .accessoryCircular], id: \.rawValue) {
            TEXGridWidgetEntryView(entry: TEXGridEntry(date: Date(), state: .normal, family: $0, isPreview: false ))
                .previewContext(WidgetPreviewContext(family: $0))
        }
    }
}

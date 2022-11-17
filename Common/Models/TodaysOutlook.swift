//
//  TodaysConditions.swift
//  TEXGrid
//
//  Created by Greg Whatley on 7/13/22.
//

import Foundation

fileprivate let formatter = DateFormatter()

fileprivate func makeDate(reference: Date, hourEnding: Int, interval: Int) -> Date {
    formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    let today = formatter.string(from: reference).split(separator: " ").first!
    let t = hourEnding == 24 ? "23:59" : "\(String(hourEnding).paddingToLeft(upTo: 2, using: "0")):\(String(interval).paddingToLeft(upTo: 2, using: "0"))"
    let str = "\(today) \(t):00"
    let date = formatter.date(from: str)
    return date!
}

class TodaysOutlook: TEXGridProvider {
    let updated: Date
    
    var actualCapacity: [DataPoint<Date, Double>] = []
    var forecatedCapacity: [DataPoint<Date, Double>] = []
    var actualDemand: [DataPoint<Date, Double>] = []
    var forecastedDemand: [DataPoint<Date, Double>] = []
    
    required init?(data _data: [String: Any]) {
        guard let lastUpdated: String = _data.get("lastUpdated"),
              let data: [[String: Any]] = _data.get("data"),
              let updatedDate = Date.from(string: lastUpdated)
        else {
            return nil
        }
        self.updated = updatedDate
        
        data.forEach({dict in
            if let demand: Int = dict.get("demand"), let capacity: Int = dict.get("capacity"), let hourEnding: Int = dict.get("hourEnding"), let interval: Int = dict.get("interval"), let isForecasted: Int = dict.get("forecast") {
                let date = makeDate(reference: self.updated, hourEnding: hourEnding, interval: interval)
                if isForecasted == 1 {
                    forecastedDemand.append(.init(x: date, y: Double(demand) / 1000))
                    forecatedCapacity.append(.init(x: date, y: Double(capacity) / 1000))
                } else {
                    actualDemand.append(.init(x: date, y: Double(demand) / 1000))
                    actualCapacity.append(.init(x: date, y: Double(capacity) / 1000))
                }
            }
        })
    }
}

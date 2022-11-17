//
//  WindSolar.swift
//  TEXGrid
//
//  Created by Greg Whatley on 7/13/22.
//

import Foundation

class WindSolar: TEXGridProvider {
    class Day {
        let date: Date
        
        private(set) var windPoints: [DataPoint<Date, Double>] = []
        private(set) var solarPoints: [DataPoint<Date, Double>] = []
        private(set) var combinedPoints: [DataPoint<Date, Double>] = []
        
        private(set) var forecastedWindPoints: [DataPoint<Date, Double>] = []
        private(set) var forecastedSolarPoints: [DataPoint<Date, Double>] = []
        private (set) var forecastedCombinedPoints: [DataPoint<Date, Double>] = []
        
        private func appendPoint(wind: Int, solar: Int, forecated: Bool, at date: Date) {
            if !forecated {
                windPoints.append(.init(x: date, y: Double(wind) / 1000))
                solarPoints.append(.init(x: date, y: Double(solar) / 1000))
                combinedPoints.append(.init(x: date, y: Double(wind + solar) / 1000))
            } else {
                forecastedWindPoints.append(.init(x: date, y: Double(wind) / 1000))
                forecastedSolarPoints.append(.init(x: date, y: Double(solar) / 1000))
                forecastedCombinedPoints.append(.init(x: date, y: Double(wind + solar) / 1000))
            }
        }
        
        init?(data _data: [String: Any]) {
            guard let _date: String = _data.get("date"),
                  let rawData: [[String: Any]] = _data.get("data"),
                  let date = Date.from(short: _date)
            else {
                return nil
            }
            self.date = date
            
            rawData.forEach({dict in
                guard let epoch: Int = dict.get("epoch") else {return}
                let date = Date(timeIntervalSince1970: Double(epoch) / 1000)
                if let copHslWind: Int = dict.get("copHslWind"), let copHslSolar: Int = dict.get("copHslSolar") {
                    if let actualWind: Int = dict.get("actualWind"), let actualSolar: Int = dict.get("actualSolar") {
                        appendPoint(wind: actualWind, solar: actualSolar, forecated: false, at: date)
                    } else {
                        appendPoint(wind: copHslWind, solar: copHslSolar, forecated: true, at: date)
                    }
                }
            })
            forecastedWindPoints.insert(windPoints.last!, at: 0)
            forecastedSolarPoints.insert(solarPoints.last!, at: 0)
            forecastedCombinedPoints.insert(combinedPoints.last!, at: 0)
        }
    }
    
    let updated: Date
    let today: Day
    
    required init?(data: [String: Any]) {
        guard let lastUpdated: String = data.get("lastUpdated"),
              let updated = Date.from(string: lastUpdated),
              let todayData: [String: Any] = data.get("currentDay"),
              let today = Day(data: todayData)
        else {
            return nil
        }
        
        self.today = today
        //self.tomorrow = tomorrow
        self.updated = updated
    }
}

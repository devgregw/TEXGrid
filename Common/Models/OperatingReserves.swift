//
//  OperatingReserves.swift
//  TEXGrid
//
//  Created by Greg Whatley on 7/13/22.
//

import Foundation

class OperatingReserves: TEXGridProvider {
    enum GridCondition: String {
        var intValue: Int {
            switch self {
            case .normal: return 1
            case .conserve: return 2
            case .emergency1, .unknown: return 3
            case .emergency2: return 4
            case .emergency3: return 5
            }
        }
        
        case normal = "normal"
        case conserve = "conservation"
        case emergency1 = "eea1"
        case emergency2 = "eea2"
        case emergency3 = "eea3"
        case unknown = "unknown"
    }
    
    class Current {
        let note: String
        let eeaLevel: Int
        let energyLevel: Int
        let state: String
        let title: String
        let value: Int
        let index: Int
        let date: Date
        var gridCondition: GridCondition {
            return .init(rawValue: state) ?? .unknown
        }
        
        init?(data: [String: Any]) {
            guard let note: String = data.get("condition_note"),
                  let eeaLevel: Int = data.get("eea_level"),
                  let energyLevel: Int = data.get("energy_level_value"),
                  let state: String = data.get("state"),
                  let title: String = data.get("title"),
                  let _value: String = data.get("prc_value"),
                  let index: Int = data.get("index"),
                  let time: Int = data.get("datetime")
            else {
                return nil
            }
            
            guard let value = Int(_value.replacingOccurrences(of: ",", with: ""), radix: 10) else {
                return nil
            }
            
            self.note = note
            self.eeaLevel = eeaLevel
            self.energyLevel = energyLevel
            self.state = state
            self.title = title
            self.value = value
            self.index = index
            self.date = Date(timeIntervalSince1970: Double(time / 1000))
        }
    }
    
    let updated: Date
    let current: Current
    public private(set) var data: [DataPoint<Date, Double>] = []
    
    required init?(data: [String: Any]) {
        guard let lastUpdate: String = data.get("lastUpdate"),
              let currentCondition: [String: Any] = data.get("current_condition"),
              let points: [[String: Any]] = data.get("data")
        else {
            return nil
        }
        
        guard let updated = Date.from(string: lastUpdate),
              let current = Current(data: currentCondition)
        else {
            return nil
        }
        
        //points = points.suffix(100)
        self.updated = updated
        self.current = current
        
        let allPoints = points.map { dict in
            let seconds = Double(dict["interval"] as! Int) / 1000
            let interval = Date(timeIntervalSince1970: seconds)
            return DataPoint(x: interval, y: Double(dict["prc"] as! Int) / 1000)
        }
         
        let startComponents = Calendar.current.dateComponents([.day, .hour], from: allPoints.first!.x)
        let maxComponents = Calendar.current.dateComponents([.day, .hour], from: allPoints.last!.x)
        var day = startComponents.day!
        var hour = startComponents.hour!
        var minute = 0
        let minuteIncrement = 10
        while day <= maxComponents.day! {
            while hour < (day == maxComponents.day! ? maxComponents.hour! + 1 : 24) {
                if let point = allPoints.first(where: {
                    let components = Calendar.current.dateComponents([.hour, .minute, .day], from: $0.x)
                    return components.hour! == hour && components.day! == day && components.minute! >= minute && components.minute! < (minute + minuteIncrement)
                }) {
                    self.data.append(point)
                }
                minute += minuteIncrement
                if minute >= 60 {
                    hour += 1
                    minute = 0
                }
                
            }
            day += 1
        }
    }
}

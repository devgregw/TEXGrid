//
//  TEXGridData.swift
//  TEXGrid
//
//  Created by Greg Whatley on 8/11/22.
//

import Foundation

protocol TEXGridProvider {
    init?(data: [String: Any])
}

class TEXGridData: ObservableObject {
    /*struct ProviderInfo {
        let name: String
        let apiUrl: String
        let description: String
    }
    
    static public let providerInfo: [String: ProviderInfo] = [
        "daily-prc": .init(name: "Operating Reserves", apiUrl: <#T##String#>, description: <#T##String#>)
    ]*/
    
    static public var previewData: TEXGridData {
        let data = TEXGridData(loadNow: false)
        if let path = Bundle.main.path(forResource: "PreviewData", ofType: "json"),
           let jsonData = try? Data(contentsOf: URL(filePath: path), options: .mappedIfSafe),
           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any] {
            data.operatingReserves = OperatingReserves(data: jsonObject["operatingReserves"] as? [String: Any] ?? [:])
            data.todaysOutlook = TodaysOutlook(data: jsonObject["todaysOutlook"] as? [String: Any] ?? [:])
            data.windSolar = WindSolar(data: jsonObject["windSolar"] as? [String: Any] ?? [:])
        }
        return data
    }
    
    @Published public fileprivate(set) var operatingReserves: OperatingReserves? = nil
    @Published public fileprivate(set) var todaysOutlook: TodaysOutlook? = nil
    @Published public fileprivate(set) var windSolar: WindSolar? = nil
    
    func usePreviewData() {
        if let path = Bundle.main.path(forResource: "PreviewData", ofType: "json"),
           let jsonData = try? Data(contentsOf: URL(filePath: path), options: .mappedIfSafe),
           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any] {
            self.operatingReserves = OperatingReserves(data: jsonObject["operatingReserves"] as? [String: Any] ?? [:])
            self.todaysOutlook = TodaysOutlook(data: jsonObject["todaysOutlook"] as? [String: Any] ?? [:])
            self.windSolar = WindSolar(data: jsonObject["windSolar"] as? [String: Any] ?? [:])
        } else {
            print("Unable to load preview data")
        }
    }
    
    func syncronizeFromUserDefaults() {
        func build<T>(from key: String) -> T? where T : TEXGridProvider {
            if let string = UserDefaults.standard.string(forKey: key), let data = string.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return .init(data: json)
            } else {
                return nil
            }
        }
        
        let os: OperatingReserves? = build(from: "daily-prc.json")
        let to: TodaysOutlook? = build(from: "todays-outlook.json")
        let ws: WindSolar? = build(from: "combine-wind-solar.json")
        
        DispatchQueue.main.async { [self] in
            operatingReserves = os ?? operatingReserves
            todaysOutlook = to ?? todaysOutlook
            windSolar = ws ?? windSolar
        }
    }
    
    init(loadNow: Bool = true) {
        if loadNow {
            Task.detached { [self] in
                await refresh(fromDefaults: false)
            }
        }
    }
    
    private func loadData<T>(from url: String) async -> T? where T: TEXGridProvider {
        if let data = await Fetch.json(from: url) {
            return .init(data: data)
        }
        return nil
    }
    
    static func getCurrentGridCondition(completion: @escaping (Date, OperatingReserves.GridCondition) -> Void) {
        Task.detached {
            if let json = await Fetch.json(from: "https://www.ercot.com/api/1/services/read/dashboards/daily-prc.json"), let current: [String: Any] = json.get("current_condition"), let raw: String = current.get("state"), let value = OperatingReserves.GridCondition(rawValue: raw) {
                completion(Date.from(string: json["lastUpdate"] as! String) ?? .now, value)
            } else {
                completion(.now, .unknown)
            }
        }
    }
    
    func refresh(fromDefaults useDefaults: Bool) async {
        if !useDefaults {
            await BackgroundTasks.loadDataImmediately()
        }
        syncronizeFromUserDefaults()
    }
}

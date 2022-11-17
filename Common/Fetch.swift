//
//  Fetch.swift
//  TEXGrid
//
//  Created by Greg Whatley on 7/18/22.
//

import Foundation

class Fetch {
    private init() {}
    
    static func json(from url: URL) async -> [String: Any]? {
        do {
            let response = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: response.0) as? [String: Any] {
                return json
            } else {
                print("JSON failed to be serialized")
                return nil
            }
        } catch let err as NSError {
            print(err)
            return nil
        }
    }
    
    static func json(from string: String) async -> [String: Any]? {
        if let url = URL(string: string) {
            return await Fetch.json(from: url)
        } else {
            print("Malformed URL")
            return nil
        }
    }
}

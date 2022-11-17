//
//  Extensions.swift
//  TEXGrid
//
//  Created by Greg Whatley on 7/13/22.
//

import Foundation

extension Date {
    static func from(string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return formatter.date(from: string)
    }
    
    var hour: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "H"
        return Int(formatter.string(from: self))!
    }
    
    static func from(short: String) -> Date? {
        return from(string: "\(short) 00:00:00")
    }
}

extension String {
    func paddingToLeft(upTo length: Int, using element: Element = " ") -> SubSequence {
        return repeatElement(element, count: Swift.max(0, length-count)) + suffix(Swift.max(count, count-length))
    }
}

extension Dictionary where Key == String, Value == Any {
    func get<T>(_ name: String) -> T? {
        return self[name] as? T
    }
}

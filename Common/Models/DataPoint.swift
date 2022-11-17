//
//  DataPoint.swift
//  TEXGrid
//
//  Created by Greg Whatley on 8/16/22.
//

import Foundation
import Charts
import UIKit

struct DataPoint<X, Y>: Comparable, Identifiable, CustomStringConvertible where X: Plottable, X: CustomStringConvertible, X: Comparable, Y: Plottable {
    static func < (lhs: DataPoint<X, Y>, rhs: DataPoint<X, Y>) -> Bool {
        return lhs.x < rhs.x
    }
    
    static func == (lhs: DataPoint<X, Y>, rhs: DataPoint<X, Y>) -> Bool {
        lhs.x == rhs.x
    }
    
    let x: X
    let y: Y
    var id: String {
        return (x as? Date)?.ISO8601Format() ?? x.description
    }
    var description: String {
        return "(\(x), \(y))"
    }
}

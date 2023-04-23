//
//  Helper.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-17.
//

import Foundation

class Helper {
    static func calculateHours(startTime: Date?, endTime: Date?, lunchTime: Int?) -> String {
        if let start = startTime, let end = endTime {
            let timeWorked = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
            let hours = (Double(timeWorked) - Double(lunchTime ?? 0)) / 3600
            return String(format: "%.2f hours", abs(hours))
        } else {
            return "--:--"
        }
    }
    static func calculateHours(startTime: Date?, endTime: Date?, lunchTime: Int?) -> Double {
        if let start = startTime, let end = endTime {
            let timeWorked = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
            let hours = (Double(timeWorked) - Double(lunchTime ?? 0)) / 3600
            return abs(hours)
        } else {
            return 0
        }
    }
}

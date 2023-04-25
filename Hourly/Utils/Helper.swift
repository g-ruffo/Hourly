//
//  Helper.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-17.
//

import Foundation

class Helper {
    static func minutesToHoursWorkedString(minutesWorked: Int16?) -> String {
        if let worked = minutesWorked {
            let hours = Double(worked) / 60
            return String(format: "%.2f hours", abs(hours))
        } else {
            return "--:--"
        }
    }
    static func minutesToHoursWorkedString(minutesWorked: Int?) -> String {
        if let worked = minutesWorked {
            let hours = Double(worked) / 60
            return String(format: "%.2f hours", abs(hours))
        } else {
            return "--:--"
        }
    }
}

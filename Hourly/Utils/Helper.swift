//
//  Helper.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-17.
//

import Foundation

// Global function that only generates print statements in debug mode.
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
    items.forEach {
        Swift.print($0, separator: separator, terminator: terminator)
    }
#endif
}

class Helper {
    static func minutesToHoursWorkedString(minutesWorked: Int32?) -> String {
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
    // Prints the location path of core data files.
    func getCoreDataPath() {
#if DEBUG
        let path = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .last?
            .absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .removingPercentEncoding
        
        print("Core Data Path = \(path ?? "Not found")")
#endif
    }
}

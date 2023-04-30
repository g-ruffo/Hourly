//
//  Helper.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-17.
//

import Foundation

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
            let path = FileManager
                .default
                .urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .last?
                .absoluteString
                .replacingOccurrences(of: "file://", with: "")
                .removingPercentEncoding

            print("Core Data Path = \(path ?? "Not found")")
        }
}

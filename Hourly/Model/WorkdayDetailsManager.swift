//
//  WorkdayDetailsManager.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-14.
//

import Foundation

struct WorkdayDetailsManager {
    // Returns the time of the input date as a string.
    func timeToDisplayString(_ date: Date?) -> String {
        if let time = date {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: time)
        } else {
            return "--:--"
        }
    }
}

//
//  WorkdayListManager.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-15.
//

import Foundation


struct WorkdayListManager {
    
    
    func dateToString(date: Date?) -> String {
        if let safeDate = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/YYYY"
            return formatter.string(from: safeDate)
        } else {
            return ""
        }
    }
}

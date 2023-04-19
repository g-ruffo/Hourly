//
//  WorkdayListManager.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-15.
//

import Foundation


struct WorkdaysManager {
    
    
    func dateToString(date: Date?) -> String {
        if let safeDate = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: safeDate)
        } else {
            return ""
        }
    }    
}

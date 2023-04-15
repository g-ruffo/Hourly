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
    
    func convertDoubleToEarnings(earnings: Double?) -> String {
        if let amount = earnings {
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.currency
           return formatter.string(from: NSNumber(value: amount)) ?? ""
        } else {
            return "$0.00"
        }
    }
    
    func calculateHours(startTime: Date?, endTime: Date?, lunchTime: Int?) -> String {
        if let start = startTime, let end = endTime {
            let timeWorked = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
            let hours = (Double(timeWorked) - Double(lunchTime ?? 0)) / 3600
            return String(format: "%.2f hours", hours)
        } else {
            return "Missing time"
        }
    }
    
}

//
//  AddEditWorkdayManager.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-15.
//

import Foundation

struct AddEditWorkdayManager {
    
    func calculateEarnings(startTime: Date?, endTime: Date?, lunchTime: Int?, payRate: Double?) -> Double {
        if let start = startTime, let end = endTime, let rate = payRate {
            let secondsPay = rate / 3600
            let timeWorked = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.currency
            let calculatedEarnings = secondsPay * Double(timeWorked)
           return calculatedEarnings
        } else {
            return 0.00
        }
    }
}

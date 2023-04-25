//
//  SummaryManager.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-22.
//

import Foundation

struct SummaryManager {
    
    private let calendar = Calendar.current
    
    func firstOfWeek(date: Date) -> Date {
        let components = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components)!
    }
    
    func lastOfWeek(date: Date) -> Date {
        let lastDay = calendar.date(byAdding: DateComponents(day: 6), to: firstOfWeek(date: date))
        return lastDay!
    }
    
    func firstOfMonth(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    func lastOfMonth(date: Date) -> Date {
        let lastDay = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstOfMonth(date: date))
        return lastDay!
    }
    
    func firstOfYear(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .day], from: firstOfMonth(date: date))
        return calendar.date(from: components)!
    }
    
    func lastOfYear(date: Date) -> Date {
        let lastDay = calendar.date(byAdding: DateComponents(month: 12, day: -1), to: firstOfYear(date: date))
        return lastDay!
    }
    
    func minutesToHours(minutes: Int32) -> String {
        let hours = Double(minutes) / 60.0
        return String(format: "%.2f Hours", hours)
    }
}

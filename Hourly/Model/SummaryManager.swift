//
//  SummaryManager.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-22.
//

import Foundation

struct SummaryManager {
    private let calendar = Calendar.current
    
    // Returns the first day of the week from the provided date.
    func firstOfWeek(date: Date) -> Date {
        let components = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components)!
    }
    // Returns the last day of the week from the provided date.
    func lastOfWeek(date: Date) -> Date {
        let lastDay = calendar.date(byAdding: DateComponents(day: 6), to: firstOfWeek(date: date))
        return lastDay!
    }
    // Returns the first day of the month from the provided date.
    func firstOfMonth(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    // Returns the last day of the month from the provided date.
    func lastOfMonth(date: Date) -> Date {
        let lastDay = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstOfMonth(date: date))
        return lastDay!
    }
    // Returns the first day of the year from the provided date.
    func firstOfYear(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .day], from: firstOfMonth(date: date))
        return calendar.date(from: components)!
    }
    // Returns the last day of the year from the provided date.
    func lastOfYear(date: Date) -> Date {
        let lastDay = calendar.date(byAdding: DateComponents(month: 12, day: -1), to: firstOfYear(date: date))
        return lastDay!
    }
    // Converts minutes into an hour double and returns the result as a string.
    func minutesToHours(minutes: Int32) -> String {
        let hours = Double(minutes) / 60.0
        return String(format: "%.2f Hours", hours)
    }
}

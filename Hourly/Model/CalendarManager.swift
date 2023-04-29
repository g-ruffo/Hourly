//
//  CalendarManager.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-11.
//

import Foundation

struct CalendarManager {
    
    private let calendar = Calendar.current
    
    // Adds one month to the input date.
    func plusMonth(date: Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    // Subtracts one month from the input date.
    func minusMonth(date: Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    // Returns the full name of the month from the input date.
    func monthString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    // Returns the year of the input date.
    func yearString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    // Returns the total number of days in month.
    func daysInMonth(date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    // Returns the current day of the input date.
    func dayOfMonth(date: Date) -> Int {
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    // Returns the first day of the month from the input date.
    func firstOfMonth(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    // Returns the last day of the month from the input date.
    func lastOfMonth(date: Date) -> Date {
        let lastDay = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstOfMonth(date: date))
        return lastDay!
    }
    // Returns the weekday number of the month from the input date.
    func weekDay(date: Date) -> Int {
        let components = calendar.dateComponents([.weekday], from: date)
        return components.weekday! - 1
    }
}

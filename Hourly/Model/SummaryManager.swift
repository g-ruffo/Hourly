//
//  SummaryManager.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-22.
//

import Foundation

struct SummaryManager {
    
    private let calendar = Calendar.current
    
    func firstOfMonth(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    func lastOfMonth(date: Date) -> Date {
        let lastDay = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstOfMonth(date: date))
        return lastDay!
    }
    
    func firstOfYear(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .day], from: date)
        return calendar.date(from: components)!
    }
    
    func lastOfYear(date: Date) -> Date {
        let lastDay = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: firstOfMonth(date: date))
        return lastDay!
    }

}

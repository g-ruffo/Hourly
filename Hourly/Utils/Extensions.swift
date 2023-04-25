//
//  Extensions.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-12.
//

import UIKit

extension UITextField {
    func isValid() -> Bool {
        guard let text = self.text,
              !text.isEmpty else {
            return false
        }
        return true
    }
    
    func currencyStringToDouble() -> Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let number = formatter.number(from: self.text!) {
            let amount = number.doubleValue
            return amount
        }
        else {
            return nil
        }
    }
}

extension Date {
    var zeroSeconds: Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: dateComponents)
    }
    func formatDateToString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: self)
    }
    func formatDateToCSVString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: self)
    }
    func formatDateToDayOfWeekString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: self)
    }
    
    func formatTimeToString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension Double {
    func convertToCurrency() -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.currency
           return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
        }
}

extension Int {
    func minutesToHoursDouble() -> Double {
        return Double (self / 60)
    }
    func minutesToSeconds() -> Int {
        return Int (self * 60)
    }
}

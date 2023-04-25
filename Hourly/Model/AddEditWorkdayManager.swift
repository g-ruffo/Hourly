//
//  AddEditWorkdayManager.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-15.
//

import UIKit

protocol AddEditWorkdayManagerDelegate: UITextFieldDelegate {
    
    func didUpdateCurrencyText(_ addEditWorkdayManager: AddEditWorkdayManager, newCurrencyValue: String?)
}

struct AddEditWorkdayManager {
    
    private var payRateAmount = 0
    
    var delegate: AddEditWorkdayManagerDelegate?
    
    
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let amount = Double(payRateAmount / 100) + Double(payRateAmount % 100) / 100
        return formatter.string(from: NSNumber(value: amount))

    }
    
    mutating func validateCurrencyInput(string: String) -> Bool {
        if payRateAmount >= 1000000 && string != "" {
            return false
        }
        if let digit = Int(string) {
            payRateAmount = payRateAmount * 10 + digit
            delegate?.didUpdateCurrencyText(self, newCurrencyValue: updateAmount())

        }
        if string == ""
        {
            payRateAmount = payRateAmount / 10
            delegate?.didUpdateCurrencyText(self, newCurrencyValue: updateAmount())
        }
        
        return false
    }
    
    func calculateEarnings(startTime: Date?, endTime: Date?, lunchTime: Int?, payRate: Double?) -> Double {
        if let start = startTime, let end = endTime, let rate = payRate {
            let secondsPay = rate / 3600
            let timeWorked = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.currency
            let calculatedEarnings = secondsPay * Double(timeWorked)
            return abs(calculatedEarnings)
        } else {
            return 0.00
        }
    }
    
    func setStartTimeDate(startTime: Date?, date: Date) -> Date? {
        var resultTime: Date?
        if let start = startTime {
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.day = Calendar.current.component(.day, from: date)
            dateComponents.month = Calendar.current.component(.month, from: date)
            dateComponents.year = Calendar.current.component(.year, from: date)
            dateComponents.hour = Calendar.current.component(.hour, from: start)
            dateComponents.minute = Calendar.current.component(.minute, from: start)
            dateComponents.second = Calendar.current.component(.second, from: start)
            resultTime = calendar.date(from: dateComponents)
        }
        return resultTime
    }
    
    func setEndTimeDate(startTime: Date?, endTime: Date?, date: Date) -> Date? {
        var resultTime: Date?
        if let start = startTime, let end = endTime {
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.day = Calendar.current.component(.day, from: date)
            dateComponents.month = Calendar.current.component(.month, from: date)
            dateComponents.year = Calendar.current.component(.year, from: date)
            dateComponents.hour = Calendar.current.component(.hour, from: end)
            dateComponents.minute = Calendar.current.component(.minute, from: end)
            dateComponents.second = Calendar.current.component(.second, from: end)
            resultTime = calendar.date(from: dateComponents)
            if let addDay = resultTime, start > addDay {
                resultTime = Calendar.current.date(byAdding: .day, value: 1, to: addDay)
            }
        }
        return resultTime
    }
    
    func calculateTimeWorkedInMinutes(startTime: Date?, endTime: Date?, lunchTime: Int?) -> Int16 {
        if let start = startTime, let end = endTime {
            let timeWorked = Int16(end.timeIntervalSince1970 - start.timeIntervalSince1970)
            let hours = (timeWorked - Int16(lunchTime ?? 0)) / 60
            return abs(hours)
        } else {
            return 0
        }
    }
}

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
    
    func setStartTimeDate(startTime: Date, date: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = Calendar.current.component(.day, from: date)
        dateComponents.month = Calendar.current.component(.month, from: date)
        dateComponents.year = Calendar.current.component(.year, from: date)
        dateComponents.hour = Calendar.current.component(.hour, from: startTime)
        dateComponents.minute = Calendar.current.component(.minute, from: startTime)
        dateComponents.second = Calendar.current.component(.second, from: startTime)
        let resultTime = calendar.date(from: dateComponents)
        if let result = resultTime { return result }
        else { fatalError() }
    }
    
    func setEndTimeDate(startTime: Date, endTime: Date, date: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = Calendar.current.component(.day, from: date)
        dateComponents.month = Calendar.current.component(.month, from: date)
        dateComponents.year = Calendar.current.component(.year, from: date)
        dateComponents.hour = Calendar.current.component(.hour, from: endTime)
        dateComponents.minute = Calendar.current.component(.minute, from: endTime)
        dateComponents.second = Calendar.current.component(.second, from: endTime)
        var resultTime = calendar.date(from: dateComponents)
        if let addDay = resultTime, startTime > addDay {
            resultTime = Calendar.current.date(byAdding: .day, value: 1, to: addDay)
        }
        if let result = resultTime { return result }
        else { fatalError() }
    }
}

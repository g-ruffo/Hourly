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
    weak var delegate: AddEditWorkdayManagerDelegate?
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let amount = Double(payRateAmount / 100) + Double(payRateAmount % 100) / 100
        return formatter.string(from: NSNumber(value: amount))

    }
    mutating func validateCurrencyInput(string: String) -> Bool {
        // Check to see if amount is within allowed limit and not empty.
        if payRateAmount >= 1000000 && !string.isEmpty {
            return false
        }
        if let digit = Int(string) {
            payRateAmount = payRateAmount * 10 + digit
            delegate?.didUpdateCurrencyText(self, newCurrencyValue: updateAmount())

        }
        if string == "" {
            payRateAmount /=  10
            delegate?.didUpdateCurrencyText(self, newCurrencyValue: updateAmount())
        }
        return false
    }
    // Calculates earnings by finding the difference between the start and end time in seconds minus the lunch time.
    func calculateEarnings(startTime: Date?, endTime: Date?, lunchMinutes: Int?, payRate: Double?) -> Double {
        if let start = startTime, let end = endTime, let rate = payRate {
            // Calculate payrate per second
            let secondsPay = rate / 3600
            var timeWorked = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
            if let lunch = lunchMinutes, lunch.minutesToSeconds() < timeWorked {
                timeWorked -= lunch.minutesToSeconds()
            }
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.currency
            let calculatedEarnings = secondsPay * Double(timeWorked)
            return abs(calculatedEarnings)
        } else {
            return 0.00
        }
    }
    // Sets the start time date to the work date selected.
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
    // Sets the end time date to the work date selected.
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
            // If end time is before start add one day.
            if let addDay = resultTime, start >= addDay {
                resultTime = Calendar.current.date(byAdding: .day, value: 1, to: addDay)
            }
        }
        return resultTime
    }
    // Calculates time worked in minutes.
    func calculateTimeWorkedInMinutes(startTime: Date?, endTime: Date?, lunchMinutes: Int?) -> Int32 {
        if let start = startTime, let end = endTime {
            var hours = 0
            let timeWorked = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
            // Make sure the lunch time is not greater than the time worked, if so return 0.
            if let lunchSeconds = lunchMinutes?.minutesToSeconds(), lunchSeconds < timeWorked {
                hours = (timeWorked - (lunchMinutes?.minutesToSeconds() ?? 0)) / 60
            } else {
                hours = timeWorked / 60
            }
            return Int32(abs(hours))
        } else {
            return 0
        }
    }
}

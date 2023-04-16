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
           return calculatedEarnings
        } else {
            return 0.00
        }
    }
}

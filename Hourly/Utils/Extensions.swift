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
    func formatDateToString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: self)
    }
    func formatTimeToString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}



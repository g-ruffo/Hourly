//
//  AddEditClientManager.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-13.
//

import Foundation
import UIKit

protocol AddEditClientManagerDelegate: UITextFieldDelegate {

    func didUpdateCurrencyText(_ addEditClientManager: AddEditClientManager, newCurrencyValue: String?)
}

struct AddEditClientManager {
    
    private var payRateAmount = 0
    
    var delegate: AddEditClientManagerDelegate?
    
    
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
}

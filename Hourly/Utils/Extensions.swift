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
              !text.trimmingCharacters(in: .whitespaces).isEmpty else {
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
    
    @IBInspectable var doneAccessory: Bool{
        get { return self.doneAccessory }
        set (hasDone) { if hasDone{ addDoneButtonOnKeyboard() } }
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() { self.resignFirstResponder() }
}

extension UITextView {    
    @IBInspectable var doneAccessory: Bool{
        get { return self.doneAccessory }
        set (hasDone) { if hasDone{ addDoneButtonOnKeyboard() } }
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}

extension Date {
    var startOfDay: Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: dateComponents) ?? self
    }
    
    var zeroSeconds: Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: dateComponents) ?? calendar.startOfDay(for: self)
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
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
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

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
}


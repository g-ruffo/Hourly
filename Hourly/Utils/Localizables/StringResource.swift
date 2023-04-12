//
//  Strings.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import Foundation

enum S: String {
    case labelTitle
    case exportTitle
    case clientsTitle
    
    var localized: String {
        NSLocalizedString(String(describing: Self.self) + "_\(rawValue)", comment: "")
    }
}

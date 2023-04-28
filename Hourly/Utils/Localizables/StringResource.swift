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
    case editClientTitle
    case addClientTitle
    case alertTitleMissingInfo
    case alertMessageMissingInfo
    case alertTitleCantConvertPhoto
    case alertMessageCantConvertPhoto
    case alertTitleDeleteConfirm
    case alertMessageDeleteConfirm

    var localized: String {
        NSLocalizedString(String(describing: Self.self) + "_\(rawValue)", comment: "")
    }
}

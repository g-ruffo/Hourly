//
//  Constants.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import Foundation


struct K {
    
    struct Identifiers {
        static let summaryNav = "SummaryNavigation"
        static let calendarNav = "CalendarNavigation"
        static let clientsNav = "ClientsNavigation"
        static let exportNav = "ExportNavigation"
        static let workdayNav = "WorkdayNavigation"
        static let settingsNav = "SettingsNavigation"
        static let workdayCell = "WorkdayCell"
        static let clientCell = "ReusableClientCell"
        static let clientNibName = "ClientCell"
        static let addEditClientNav = "AddEditClientNavigation"
        static let settingsCell = "SettingsReusableCell"
        static let settingsNibName = "SettingsCell"
        static let calendarCell = "CalendarCell"



    }
    
    struct NavigationBar {
        static let middleButtonSize: CGFloat = 64
        static let middleButtonRadius: CGFloat = middleButtonSize / 2
    }
}

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
        static let workdayNav = "WorkdayNavigation"
        static let settingsNav = "SettingsNavigation"
        static let workdayNibName = "WorkdayCell"
        static let workdayCell = "ReusableWorkdayCell"
        static let clientCell = "ReusableClientCell"
        static let clientNibName = "ClientCell"
        static let addEditClientNav = "AddEditClientNavigation"
        static let settingsCell = "SettingsReusableCell"
        static let settingsNibName = "SettingsCell"


    }
    
    struct NavigationBar {
        static let middleButtonSize: CGFloat = 64
        static let middleButtonRadius: CGFloat = middleButtonSize / 2
    }
}

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
        static let clientCell = "ClientCell"
        static let addClientNav = "AddClientNavigation"
        static let editClientNav = "EditClientNavigation"
        static let detailClientNav = "DetailClientNavigation"
        static let settingsCell = "SettingsReusableCell"
        static let settingsNibName = "SettingsCell"
        static let calendarCell = "CalendarCell"
        static let workDetailNav = "WorkDetailNavigation"
    }
    
    struct Cell {
        static let workDescriptionCell = "WorkDescriptionCell"
        static let workHoursPayRateCell = "WorkHoursPayRateCell"
        static let workLocationCell = "WorkLocationCell"
        static let workMileageCell = "WorkMileageCell"
        static let workStartEndTimeCell = "WorkStartEndTimeCell"
    }

    struct NavigationBar {
        static let middleButtonSize: CGFloat = 64
        static let middleButtonRadius: CGFloat = middleButtonSize / 2
    }
}

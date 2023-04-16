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
    }
    
    struct Cell {
        static let workdayImageCell = "WorkdayImageCell"

    }
    
    struct Segue {
        static let workDetailNav = "WorkDetailNavigation"
        static let editWorkdayNav = "EditWorkdayNavigation"
    }
    
    struct UserDefaultsKey {
        static let client = "workdayClientName"
        static let date = "workdayDate"
        static let location = "workdayLocation"
        static let start = "workdayStartTime"
        static let end = "workdayEndTime"
        static let lunch = "workdayLunch"
        static let rate = "workdayPayRate"
        static let mileage = "workdayMileage"
        static let description = "workdayDescription"
    }

    struct NavigationBar {
        static let middleButtonSize: CGFloat = 64
        static let middleButtonRadius: CGFloat = middleButtonSize / 2
    }
}

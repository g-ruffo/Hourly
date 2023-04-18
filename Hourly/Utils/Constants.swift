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
        static let workdaysNav = "ClientsNavigation"
        static let exportNav = "ExportNavigation"
        static let newWorkdayNav = "WorkdayNavigation"
        static let settingsNav = "SettingsNavigation"
        static let workdayCell = "WorkdayCell"
        static let clientCell = "ClientCell"
        static let addClientNav = "AddClientNavigation"
        static let detailClientNav = "DetailClientNavigation"
        static let settingsCell = "SettingsReusableCell"
        static let settingsNibName = "SettingsCell"
        static let calendarCell = "CalendarCell"
    }
    
    struct NotificationKeys{
        private static let workdaysUpdated = "ca.veltus.hourly.notification.workdaysUpdated"
        static let updateWorkdaysNotification = Notification.Name(rawValue: workdaysUpdated)
    }
    
    struct Cell {
        static let workdayImageCell = "WorkdayImageCell"
        static let clientSearchCell = "ClientSearchCell"

    }
    
    struct Segue {
        static let workDetailNav = "WorkDetailNavigation"
        static let editWorkdayNav = "EditWorkdayNavigation"
        static let clientsNav = "ClientsNavigation"
        static let editClientNav = "EditClientNavigation"
    }
    
    struct UserDefaultsKey {
        static let clientName = "workdayClientName"
        static let date = "workdayDate"
        static let location = "workdayLocation"
        static let start = "workdayStartTime"
        static let end = "workdayEndTime"
        static let lunch = "workdayLunch"
        static let rate = "workdayPayRate"
        static let mileage = "workdayMileage"
        static let description = "workdayDescription"
        static let client = "existingClient"

    }

    struct NavigationBar {
        static let middleButtonSize: CGFloat = 64
        static let middleButtonRadius: CGFloat = middleButtonSize / 2
    }
}

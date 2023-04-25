//
//  ExportManager.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-24.
//

import Foundation

struct ExportManager {
    
    func exportWorkdaysToCSV(withObjects data: [WorkdayItem], client: String, startDate: Date, endDate: Date, toPath url: URL) {
        var counter = 0
        
        var totalMinutesWorked: Int = 0
        var totalEarnings: Double = 0.0
        var totalMileage = 0
        
        let fileName = "\(client)_(\(startDate.formatDateToCSVString())-\(endDate.formatDateToCSVString())"
        let fileExtension = "csv"
        var exportCSVString = " , , ,\(client),\(startDate.formatDateToCSVString()), - ,\(endDate.formatDateToCSVString()), , , \n"
        let spacer = " , , , , , , , , , \n"
        let categoryLabels = "Date, Start Time, End Time, Lunch Break, Hours, Mileage, Location, Details, Rate, Total Earnings \n"
        
        let summaryLabels = " , , , , Hours, Mileage, , , , Total Earnings \n"
        exportCSVString.append(spacer)
        exportCSVString.append(categoryLabels)
        
        data.forEach { item in
            let date = String(describing: item.date?.formatDateToDayOfWeekString())
            let start = String(describing: item.startTime?.formatTimeToString())
            let end = String(describing: item.endTime?.formatTimeToString())
            let lunch = "\(String(describing: item.lunchBreak)) min"
            let hours = String(describing: Helper.minutesToHoursWorkedString(minutesWorked: item.minutesWorked))
            let mileage = String(describing: item.mileage)
            let location = String(describing: item.location)
            let details = String(describing: item.workDescription)
            let rate = String(describing: item.payRate.convertToCurrency())
            let earnings = String(describing: item.earnings.convertToCurrency())
            
            totalMinutesWorked += Int(item.minutesWorked)
            totalEarnings += item.earnings
            totalMileage += Int(item.mileage)
            
            let entityContent = "\(date), \(start), \(end), \(lunch), \(hours), \(mileage), \(location), \(details), \(rate), \(earnings) \n"
            exportCSVString.append(entityContent)
        }
        
        exportCSVString.append(spacer)
        exportCSVString.append(summaryLabels)
        
        let summaryValues = " , , , , \(String(describing: Helper.minutesToHoursWorkedString(minutesWorked: totalMinutesWorked))), \(String(describing: totalMileage)), , , , \(String(describing: totalEarnings.convertToCurrency())) \n"
        
        exportCSVString.append(summaryValues)
        
        let fileManager = FileManager.default

        var path = url.appendingPathComponent("\(fileName).\(fileExtension)")
                
        if (!fileManager.fileExists(atPath: path.path)) {
            fileManager.createFile(atPath: path.path, contents: nil)
        } else {
            while fileManager.fileExists(atPath: path.path) {
                   counter += 1
                   let newFileName =  "\(fileName)_\(counter).\(fileExtension)"
                path = url.appendingPathComponent(newFileName)
               }
        }
        do {
            try exportCSVString.write(to: path, atomically: true, encoding: .utf8)
        } catch let error {
            print("Error creating CSV = \(error.localizedDescription)")
        }
    }
}

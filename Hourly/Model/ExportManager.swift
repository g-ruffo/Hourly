//
//  ExportManager.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-24.
//

import Foundation

struct ExportManager {
    
    mutating func exportWorkdaysToCSV(withObjects data: [WorkdayItem], toPath url: URL) {
        var counter = 0
        var fileName = "Export"
        var exportCSVString = "Client, Date, Earnings\n"
        data.forEach { item in
            let entityContent = "\(String(describing: item.clientName)), \(String(describing: item.date)), \(String(describing: item.earnings))\n"
            exportCSVString.append(entityContent)
        }
        
        let fileManager = FileManager.default

        var path = url.appendingPathComponent("\(fileName).csv")
                
        if (!fileManager.fileExists(atPath: path.path)) {
            fileManager.createFile(atPath: path.path, contents: nil)
        } else {
            while fileManager.fileExists(atPath: path.path) {
                   counter += 1
                   let newFileName =  "\(fileName)_\(counter).csv"
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

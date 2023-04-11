//
//  TestDays.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import Foundation


struct TestDay {
    let client: String
    let date: String
    let earnings: String
    let hoursWorked: String
    
    init(client: String = "Glacier West", date: String = "July \(Int.random(in: 1...30)) 2022", earnings: String = "$\(Int.random(in: 10...999)).00", hoursWorked: String = "\(Int.random(in: 1...19)) hours") {
        self.client = client
        self.date = date
        self.earnings = earnings
        self.hoursWorked = hoursWorked
    }
}


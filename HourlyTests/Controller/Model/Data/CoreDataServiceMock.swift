//
//  CoreDataServiceMock.swift
//  HourlyTests
//
//  Created by Grayson Ruffo on 2023-04-29.
//

import Foundation
@testable import Hourly
import CoreData

class CoreDataServiceMock: CoreDataServiceDelegate {
    weak var delegate: CoreDataServiceDelegate?

    func getClientFromID(_ id: NSManagedObjectID?) {
        let client = ClientItem()
        client.companyName = "Superman"
        client.contactName = "Eric"
        client.phoneNumber = "6049999999"
    }
}

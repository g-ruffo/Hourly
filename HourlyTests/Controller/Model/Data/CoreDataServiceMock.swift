//
//  CoreDataServiceMock.swift
//  HourlyTests
//
//  Created by Grayson Ruffo on 2023-04-29.
//

import Foundation
@testable import Hourly
import CoreData

final class CoreDataServiceMock: CoreDataService {
    
    func createDate(day: Int = 1, hour: Int = 0) -> Date {
        let date = Date()
        var dateComponents = DateComponents()
        dateComponents.year = date.get(.year)
        dateComponents.month = date.get(.month)
        dateComponents.day = date.get(.day)
        dateComponents.hour = hour
        dateComponents.minute = 0

        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: dateComponents)!
    }
    
    
    

    override func createUpdateWorkday(clientName: String, date workDate: Date, start: Date?, end: Date?, lunch: Int32, mileage: Int32, rate: Double, location: String?, description: String?, timeWorked: Int32, earnings: Double, isDraft: Bool) -> Bool {
        return true
    }
    
    override func addPhotoItemsToWorkday(_ workday: WorkdayItem) {
        
    }
    
    override func createPhotoItems(from jpegImages: Array<Data?>) {
        
    }
    
    override func deleteWorkday() -> Bool {
        return true
        
    }
    
    override func deletePhoto(at index: Int) {
        
    }
    
    override func updatePhoto(at index: Int, text: String) {
        
    }
    
    override func getClientFromURL(url: URL) {
        
    }
    
    override func getWorkdayFromObjectId(_ id: NSManagedObjectID) {
        
    }
    override func getWorkdays(withRequest request : NSFetchRequest<WorkdayItem>) {
        var array: [WorkdayItem] = []
        let client = ClientItem()
        client.address = "15432 70th Ave, Vancouver BC"
        client.companyName = "Veltus"
        client.contactName = "Alex"
        client.phoneNumber = "6047766655"
        client.email = "test@mock.com"
        client.payRate = 40.00
        
        for i in 1...10 {
            let day = WorkdayItem()
            day.client = client
            day.clientName = client.companyName
            day.date = createDate(day: i)
            day.startTime = createDate(day: i)
            day.endTime = createDate(day: 10)
            day.earnings = 400.00
            day.isFinalized = true
            day.mileage = Int32(i * 10)
            day.lunchMinutes = Int32(i * 10)
            day.location = client.address
            day.minutesWorked = 600
            day.payRate = client.payRate
            array.append(day)
        }
        delegate?.loadedWorkdays(self, workdayItems: array)
        
    }
    
    override func getWorkdayClientID() -> URL? {
        return nil
    }
    
    override func getClients(withRequest request : NSFetchRequest<ClientItem>) {
        
    }
    
    override func getClientFromID(_ id: NSManagedObjectID?) {
        
    }
    
    override func deleteClient() -> Bool {
        return true
        
    }
    
    override func createUpdateClient(companyName: String, contactName: String?, phone: String?, email: String?, address: String?, rate: Double, tagColour: String?) -> Bool {
        return true
    }
}

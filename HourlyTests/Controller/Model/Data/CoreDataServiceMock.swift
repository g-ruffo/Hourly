//
//  CoreDataServiceMock.swift
//  HourlyTests
//
//  Created by Grayson Ruffo on 2023-04-29.
//

import Foundation
@testable import Hourly
import CoreData

final class CoreDataServiceMock: CoreDataServiceProtocol {
    weak var delegate: CoreDataServiceDelegate?

    func createUpdateWorkday(clientName: String, date workDate: Date, start: Date?, end: Date?, lunch: Int32, mileage: Int32, rate: Double, location: String?, description: String?, timeWorked: Int32, earnings: Double, isDraft: Bool) -> Bool {
        return true
    }
    
    func addPhotoItemsToWorkday(_ workday: WorkdayItem) {
        
    }
    
    func createPhotoItems(from jpegImages: Array<Data?>) {
        
    }
    
    func deleteWorkday() -> Bool {
        return true
        
    }
    
    func deletePhoto(at index: Int) {
        
    }
    
    func updatePhoto(at index: Int, text: String) {
        
    }
    
    func getClientFromURL(url: URL) {
        
    }
    
    func getWorkdayFromObjectId(_ id: NSManagedObjectID) {
        
    }
    func getWorkdays(withRequest request : NSFetchRequest<WorkdayItem>) {
        
    }
    
    func getWorkdayClientID() -> URL? {
        return nil
    }
    
    func getClients(withRequest request : NSFetchRequest<ClientItem>) {
        
    }
    
    func getClientFromID(_ id: NSManagedObjectID?) {
        
    }
    
    func deleteClient() -> Bool {
        return true
        
    }
    
    func createUpdateClient(companyName: String, contactName: String?, phone: String?, email: String?, address: String?, rate: Double, tagColour: String?) -> Bool {
        return true
    }
}

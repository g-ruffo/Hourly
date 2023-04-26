//
//  CoreDataService.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-25.
//

import Foundation
import UIKit
import CoreData

protocol CoreDataServiceDelegate {
    func loadedWorkday(_ coreDataService: CoreDataService, workdayItem: WorkdayItem?)
    func loadedWorkdays(_ coreDataService: CoreDataService, workdayItems: Array<WorkdayItem>)
    func loadedPhotos(_ coreDataService: CoreDataService, photoItems: Array<PhotoItem>)
    func loadedClient(_ coreDataService: CoreDataService, clientItem: ClientItem?)
    func loadedClients(_ coreDataService: CoreDataService, clientItems: Array<ClientItem>)
}

extension CoreDataServiceDelegate {
    func loadedWorkday(_ coreDataService: CoreDataService, workdayItem: WorkdayItem?) {}
    func loadedWorkdays(_ coreDataService: CoreDataService, workdayItems: Array<WorkdayItem>) {}
    func loadedPhotos(_ coreDataService: CoreDataService, photoItems: Array<PhotoItem>) {}
    func loadedClient(_ coreDataService: CoreDataService, clientItem: ClientItem?) {}
    func loadedClients(_ coreDataService: CoreDataService, clientItems: Array<ClientItem>) {}

}
final class CoreDataService {
    
    private var workday: WorkdayItem? {
        didSet { delegate?.loadedWorkday(self, workdayItem: workday) }
    }
    
    private var workdays: Array<WorkdayItem> = [] {
        didSet { delegate?.loadedWorkdays(self, workdayItems: workdays) }
    }
    
    private var workdayPhotos: Array<PhotoItem> = [] {
        didSet { delegate?.loadedPhotos(self, photoItems: workdayPhotos) }
    }
    private var client: ClientItem? {
        didSet { delegate?.loadedClient(self, clientItem: client) }
    }
    
    private var clients: Array<ClientItem> = [] {
        didSet { delegate?.loadedClients(self, clientItems: clients) }
    }
    
    private var clientId: NSManagedObjectID?
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var delegate: CoreDataServiceDelegate?
    
    //MARK: - Create Workday Methods
    func createUpdateWorkday(clientName: String, date: Date, start: Date?, end: Date?, lunch: Int32, mileage: Int32, rate: Double, location: String?, description: String?, timeWorked: Int32, earnings: Double, isDraft: Bool) -> Bool {
        
        let workday = workday ?? WorkdayItem(context: databaseContext)
        workday.clientName = clientName
        workday.date = date
        workday.startTime = start
        workday.endTime = end
        workday.lunchMinutes = lunch
        workday.mileage = mileage
        workday.payRate = rate
        workday.location = location
        workday.workDescription = description
        workday.minutesWorked = timeWorked
        workday.earnings = earnings
        workday.isFinalized = !isDraft
        workday.client = client
        addPhotoItemsToWorkday(workday)
        return saveWorkday()
        
    }

    func addPhotoItemsToWorkday(_ workday: WorkdayItem) {
            for photo in workdayPhotos {
                photo.workingDay = workday
        }
    }
    
    func createPhotoItems(from jpegImages: Array<Data?>) {
        let date = Date()
        jpegImages.forEach { jpegImage in
            let photoItem = PhotoItem(context: databaseContext)
            photoItem.image = jpegImage
            photoItem.imageDescription = "Date: \(date.formatDateToString())"
            workdayPhotos.append(photoItem)
        }
    }
    
    //MARK: - Delete Workday Methods
    func deleteWorkdayFromDatabase() -> Bool {
        if let day = workday {
            databaseContext.delete(day)
            return saveWorkday()
        } else { return false }
    }
    
    func deletePhoto(at index: Int) {
        let photo = workdayPhotos[index]
        databaseContext.delete(photo)
        workdayPhotos.remove(at: index)
    }
    
    
    //MARK: - Workday Save Methods
    func saveWorkday() -> Bool {
        if databaseContext.hasChanges {
            do {
                try databaseContext.save()
                return true
            } catch {
                print("Error saving workday to database = \(error)")
                return false
            }
        } else {
            return true
        }
    }
    
    //MARK: - Workday Get Methods
    func getClientFromURL(url: URL) {
        let clientObjectId = databaseContext.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: url)
        if let id = clientObjectId { getClientFromID(id) }
        
    }
    
    func getWorkdayFromObjectId(_ id: NSManagedObjectID) {
            do {
                workday = try databaseContext.existingObject(with: id) as? WorkdayItem
                client = workday?.client
                workdayPhotos = workday?.photos?.allObjects as? Array<PhotoItem> ?? []
            } catch {
                fatalError(error.localizedDescription)
            }
    }
    
    
    //MARK: - Client Get Methods
    
    func getClientItems(withRequest request : NSFetchRequest<ClientItem>) {
        do {
            clients = try databaseContext.fetch(request)
        } catch {
            print("Error while fetching data: \(error)")
        }
    }
    
    func getClientFromID(_ id: NSManagedObjectID?) {
        clientId = id
        if let clientId = id {
            do {
                client = try databaseContext.existingObject(with: clientId) as? ClientItem
                delegate?.loadedClient(self, clientItem: client)
            } catch {
                fatalError(error.localizedDescription)
            }
        } else if client != nil {
            client = nil
            delegate?.loadedClient(self, clientItem: client)
        }
    }
    
    func getWorkdayClientID() -> URL? {
        return clientId?.uriRepresentation()
    }
}




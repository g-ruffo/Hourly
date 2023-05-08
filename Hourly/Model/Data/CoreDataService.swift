//
//  CoreDataService.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-25.
//

import Foundation
import UIKit
import CoreData

protocol CoreDataServiceDelegate: AnyObject {
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

class CoreDataService {
    private var workday: WorkdayItem? {
        didSet { delegate?.loadedWorkday(self, workdayItem: workday) }
    }
    private var workdays: Array<WorkdayItem> = [] {
        didSet { delegate?.loadedWorkdays(self, workdayItems: workdays) }
    }
    private var _workdayPhotos: Array<PhotoItem> = [] {
        didSet { delegate?.loadedPhotos(self, photoItems: _workdayPhotos) }
    }
    var workdayPhotos: Array<PhotoItem> { get { return _workdayPhotos } }
    private var client: ClientItem? {
        didSet { delegate?.loadedClient(self, clientItem: client) }
    }
    private var clients: Array<ClientItem> = [] {
        didSet { delegate?.loadedClients(self, clientItems: clients) }
    }
    private var clientId: NSManagedObjectID?
    private let databaseContext: NSManagedObjectContext
    weak var delegate: CoreDataServiceDelegate?
    
    init(databaseContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.databaseContext = databaseContext
    }
    
    //MARK: - Save Methods
    func saveToDatabase() -> Bool {
        if databaseContext.hasChanges {
            do {
                try databaseContext.save()
                return true
            } catch {
                print("Error saving files to core data = \(error)")
                return false
            }
        } else {
            return true
        }
    }
    
    //MARK: - Create Workday Methods
    func createUpdateWorkday(clientName: String, date workDate: Date, start: Date?, end: Date?, lunch: Int32, mileage: Int32, rate: Double, location: String?, description: String?, timeWorked: Int32, earnings: Double, isDraft: Bool) -> Bool {
        // If workday is nil, the user is trying to create a new object. Else, user is updating existing object.
        let workday = workday ?? WorkdayItem(context: databaseContext)
        workday.clientName = clientName
        workday.date = workDate
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
        return saveToDatabase()
    }
    
    func addPhotoItemsToWorkday(_ workday: WorkdayItem) {
        for photo in _workdayPhotos {
            photo.workingDay = workday
        }
    }
    
    func createPhotoItems(from jpegImages: Array<Data?>) {
        let date = Date()
        var items: Array<PhotoItem> = []
        jpegImages.forEach { jpegImage in
            let photoItem = PhotoItem(context: databaseContext)
            photoItem.image = jpegImage
            photoItem.imageDescription = "Date: \(date.formatDateToString())"
            items.append(photoItem)
        }
        _workdayPhotos.append(contentsOf: items)
    }
    
    //MARK: - Delete Workday Methods
    func deleteWorkday() -> Bool {
        if let day = workday {
            databaseContext.delete(day)
            return saveToDatabase()
        } else { return false }
    }
    
    func deletePhoto(at index: Int) {
        databaseContext.delete(_workdayPhotos[index])
        _workdayPhotos.remove(at: index)
    }
    
    //MARK: - Update Workday Methods
    func updatePhoto(at index: Int, text: String) {
        _workdayPhotos[index].imageDescription = text
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
            _workdayPhotos = workday?.photos?.allObjects as? Array<PhotoItem> ?? []
        } catch {
            print("Error loading files from core data = \(error)")
        }
    }
    
    func getWorkdays(withRequest request : NSFetchRequest<WorkdayItem>) {
        do{
            workdays = try databaseContext.fetch(request)
        } catch {
            print("Error fetching clients from database = \(error)")
        }
    }
    
    func getWorkdayClientID() -> URL? {
        return clientId?.uriRepresentation()
    }
    
    //MARK: - Client Get Methods
    func getClients(withRequest request : NSFetchRequest<ClientItem>) {
        do {
            clients = try databaseContext.fetch(request)
        } catch {
            print("Error while fetching data: \(error)")
        }
    }
    
    func getClientFromID(_ id: NSManagedObjectID?) {
        clientId = id
        if let clientId = id {
            do { client = try databaseContext.existingObject(with: clientId) as? ClientItem }
            catch { fatalError(error.localizedDescription) }
        } else if client != nil { client = nil }
    }
    
    //MARK: - Client Delete Methods
    func deleteClient() -> Bool {
        if let deleteClient = client {
            databaseContext.delete(deleteClient)
            return saveToDatabase()
        } else { return false }
    }
    
    //MARK: - Create Client Methods
    func createUpdateClient(companyName: String, contactName: String?, phone: String?, email: String?, address: String?, rate: Double, tagColour: String?) -> Bool {
        // If client is nil, the user is trying to create a new object. Else, user is updating existing object.
        let client = client ?? ClientItem(context: databaseContext)
        client.companyName = companyName
        client.contactName = contactName
        client.phoneNumber = phone
        client.email = email
        client.address = address
        client.payRate = rate
        client.tagColour = tagColour
        return saveToDatabase()
    }
}




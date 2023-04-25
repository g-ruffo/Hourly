//
//  CoreDataService.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-25.
//

import Foundation
import UIKit
import CoreData


struct CoreDataService {
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getClientFromID(id: NSManagedObjectID) -> ClientItem? {
        do {
            return try databaseContext.existingObject(with: id) as? ClientItem
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}



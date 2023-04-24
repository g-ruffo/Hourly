//
//  ExportViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-12.
//

import UIKit
import CoreData

class ExportViewController: UIViewController {
    
    
    @IBOutlet weak var clientTextField: ClientSearchTextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    private var workdays: Array<WorkdayItem> = []
    
    private var selectedClient: ClientItem?
    
    private var selectedClientID: NSManagedObjectID? {
        didSet {
            if let id = selectedClientID {
                do {
                    selectedClient = try databaseContext.existingObject(with: id) as? ClientItem
                } catch {
                    fatalError(error.localizedDescription)
                }
            } else {
                if selectedClient != nil {
                    selectedClient = nil
                }
            }
        }
    }
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        clientTextField.searchDelegate = self
    }
    
    
    @IBAction func exportButtonPressed(_ sender: UIButton) {
        if loadWorkdaysFromDatabase() {
            if workdays.count > 0 {
                
            } else {
                showAlertDialog()
            }
        } else {
            showAlertDialog()
        }
    }
    
    func showAlertDialog() {
        let alert = UIAlertController(title: "No Data Found", message: "There are no workdays found for the client and dates you have selected", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadWorkdaysFromDatabase() -> Bool {
        var startDate = startDatePicker.date
        var endDate = endDatePicker.date
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        let sortDate = NSSortDescriptor(key: "date", ascending: false)
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND isFinalized == true", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [sortDate]
        do{
            workdays = try databaseContext.fetch(request)
            return true
        } catch {
            print("Error fetching workdays from database = \(error)")
            return false
        }
    }
    
    
}


//MARK: - ClientSearchDelegate
extension ExportViewController: ClientSearchDelegate {
    func selectedExistingClient(_ clientSearchTextField: ClientSearchTextField, clientID: NSManagedObjectID?) {
        self.selectedClientID = clientID
    }
}

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
    @IBOutlet weak var startDatePicker: UIDatePicker! {
        didSet {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            startDatePicker.date = calendar.startOfDay(for: startDatePicker.date)
        }
    }
    @IBOutlet weak var endDatePicker: UIDatePicker! {
        didSet {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            endDatePicker.date = calendar.startOfDay(for: endDatePicker.date)
        }
    }
    
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?

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

    private var manager = ExportManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clientTextField.searchDelegate = self
        startDatePicker.tag = 0
        endDatePicker.tag = 1
        startDatePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)

    }
    
    @objc func datePickerChanged(picker: UIDatePicker) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        if startDatePicker.date.timeIntervalSince1970 > endDatePicker.date.timeIntervalSince1970 {
            endDatePicker.date = startDatePicker.date
        }
        switch picker.tag {
        case 0: startDatePicker.date = calendar.startOfDay(for: startDatePicker.date)
        case 1: endDatePicker.date = calendar.startOfDay(for: endDatePicker.date)
        default: print("Error unknow date picker tag")
        }
    }
    
    
    @IBAction func exportButtonPressed(_ sender: UIButton) {
        if loadWorkdaysFromDatabase() {
            if workdays.count > 0 {
                
                // Create a document picker for directories.
                let documentPicker =
                UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
                documentPicker.delegate = self
                
                // Present the document picker.
                present(documentPicker, animated: true, completion: nil)
                
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
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        let sortDate = NSSortDescriptor(key: "date", ascending: false)
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND isFinalized == true", startDatePicker.date as NSDate, endDatePicker.date as NSDate)
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

//MARK: - UIDocumentPickerDelegate
extension ExportViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        // Start accessing a security-scoped resource.
        guard url.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            return
        }
        // Make sure you release the security-scoped resource when you finish.
        defer { url.stopAccessingSecurityScopedResource() }
        
        manager.exportWorkdaysToCSV(withObjects: workdays, toPath: url)
        url.stopAccessingSecurityScopedResource()
    }
}

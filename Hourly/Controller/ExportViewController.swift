//
//  ExportViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-12.
//

import UIKit
import CoreData

class ExportViewController: UIViewController {
    // MARK: - Variables
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var clientTextField: ClientSearchTextField!
    @IBOutlet weak var startDatePicker: UIDatePicker! {
        didSet {
            // Set the initial time for the date to start of day.
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            startDatePicker.date = calendar.startOfDay(for: startDatePicker.date)
        }
    }
    @IBOutlet weak var endDatePicker: UIDatePicker! {
        didSet {
            // Set the initial time for the date to start of day.
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            endDatePicker.date = calendar.startOfDay(for: endDatePicker.date)
        }
    }
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
    private var workdays: Array<WorkdayItem> = []
    private var selectedClient: ClientItem?
    private let coreDataService = CoreDataService()
    private var manager = ExportManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegate and data source.
        coreDataService.delegate = self
        clientTextField.searchDelegate = self
        startDatePicker.tag = 0
        endDatePicker.tag = 1
        // Add targets to listen for changes in the date pickers.
        startDatePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        // Set the export buttons background colour.
        exportButton.tintColor = UIColor("#F1C40F")
    }
    
    @objc func datePickerChanged(picker: UIDatePicker) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        // Check if start date is after end date and if so set the end date to equal the start date.
        if startDatePicker.date.timeIntervalSince1970 > endDatePicker.date.timeIntervalSince1970 {
            endDatePicker.date = startDatePicker.date
        }
        // Determine which date picker was updated and set its time to start of day.
        switch picker.tag {
        case 0: startDatePicker.date = calendar.startOfDay(for: startDatePicker.date)
        case 1: endDatePicker.date = calendar.startOfDay(for: endDatePicker.date)
        default: print("Error unknow date picker tag")
        }
        // Dismiss date picker after selection is made.
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    // Called when the export button is pressed.
    @IBAction func exportButtonPressed(_ sender: UIButton) { loadWorkdaysFromDatabase() }
    
    func showAlertDialog(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadWorkdaysFromDatabase() {
        // If no client has been selected show alert and return.
        guard let client = selectedClient else {
            showAlertDialog(title: S.alertTitleNoClientSelected.localized,
                            message: S.alertMessageNoClientSelected.localized)
            return
        }
        // Create request using the provided dates and client.
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        let sortDate = NSSortDescriptor(key: "date", ascending: false)
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND isFinalized == true AND client == %@", startDatePicker.date as NSDate, endDatePicker.date as NSDate, client)
        request.sortDescriptors = [sortDate]
        coreDataService.getWorkdays(withRequest: request)
    }
}

// MARK: - ClientSearchDelegate
extension ExportViewController: ClientSearchDelegate {
    func selectedExistingClient(_ clientSearchTextField: ClientSearchTextField, clientID: NSManagedObjectID?) {
        coreDataService.getClientFromID(clientID)
    }
    
    func didEndEditing(_ clientSearchTextField: ClientSearchTextField) {
        // If the user finishes editing without selecting a client set the text field back to nil.
        guard let _ = self.selectedClient else {
            self.clientTextField.text = nil
            return
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension ExportViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        // Start accessing a security-scoped resource.
        guard url.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            return
        }
        // Make sure you release the security-scoped resource when you finish.
        defer { url.stopAccessingSecurityScopedResource() }
        manager.exportWorkdaysToCSV(withObjects: workdays, client: (selectedClient?.companyName)!, startDate: startDatePicker.date, endDate: endDatePicker.date, toPath: url)
        url.stopAccessingSecurityScopedResource()
    }
}

// MARK: - CoreDataServiceDelegate
extension ExportViewController: CoreDataServiceDelegate {
    func loadedClient(_ coreDataService: CoreDataService, clientItem: ClientItem?) {
        selectedClient = clientItem
    }
    
    func loadedWorkdays(_ coreDataService: CoreDataService, workdayItems: Array<WorkdayItem>) {
        workdays = workdayItems
        if workdays.count > 0 {
            // Create a document picker for directories.
            let documentPicker =
            UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
            documentPicker.delegate = self
            // Present the document picker.
            present(documentPicker, animated: true, completion: nil)
        } else {
            // Show alert if no entries are found for the selected time and client.
            showAlertDialog(title: S.alertTitleNoData.localized,
                            message: S.alertMessageNoData.localized)
        }
    }
}

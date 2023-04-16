//
//  WorkdayViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit

class AddEditWorkdayViewController: UIViewController {

    @IBOutlet weak var clientTexfield: UITextField!
    @IBOutlet weak var dateTexfield: UITextField!
    @IBOutlet weak var locationTexfield: UITextField!
    @IBOutlet weak var startTimeTexfield: UITextField!
    @IBOutlet weak var endTimeTexfield: UITextField!
    @IBOutlet weak var lunchTexfield: UITextField!
    @IBOutlet weak var payRateTexfield: UITextField!
    @IBOutlet weak var mileageTexfield: UITextField!
    @IBOutlet weak var descriptionTexfield: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var workday: WorkdayItem?

    private let datePicker = UIDatePicker()
    private let startTimePicker = UIDatePicker()
    private let endTimePicker = UIDatePicker()
    private var selectedDate: Date?
    private var selectedStartTime: Date?
    private var selectedEndTime: Date?
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDatePicker()
        setupTimePickers()
    }
    
    func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateValueChange), for: .valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        dateTexfield.inputView = datePicker
        selectedDate = Date().zeroSeconds
        dateTexfield.text = Date().formatDateToString()
    }
    
    func setupTimePickers() {
        startTimePicker.datePickerMode = .time
        endTimePicker.datePickerMode = .time
        startTimePicker.addTarget(self, action: #selector(startTimeValueChange), for: .valueChanged)
        endTimePicker.addTarget(self, action: #selector(endTimeValueChange), for: .valueChanged)
        startTimePicker.frame.size = CGSize(width: 0, height: 300)
        endTimePicker.frame.size = CGSize(width: 0, height: 300)
        startTimePicker.preferredDatePickerStyle = .wheels
        endTimePicker.preferredDatePickerStyle = .wheels
        startTimeTexfield.inputView = startTimePicker
        endTimeTexfield.inputView = endTimePicker
    }
    
    @objc func dateValueChange(_ datePicker: UIDatePicker) {
        dateTexfield.text = datePicker.date.formatDateToString()
        selectedDate = datePicker.date.zeroSeconds
    }
    
    @objc func startTimeValueChange(_ datePicker: UIDatePicker) {
        startTimeTexfield.text = startTimePicker.date.formatTimeToString()
        selectedStartTime = datePicker.date.zeroSeconds
    }
    
    @objc func endTimeValueChange(_ datePicker: UIDatePicker) {
        endTimeTexfield.text = endTimePicker.date.formatTimeToString()
        selectedEndTime = datePicker.date.zeroSeconds
    }
    
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
    
    func createWorkday() -> Bool {
        print("clientTexfield.text = \(clientTexfield.text)")
        print("selectedDate = \(selectedDate)")
        print("selectedStartTime = \(selectedStartTime)")
        print("selectedEndTime = \(selectedEndTime)")
        print("payRateTexfield.currencyStringToDouble() = \(payRateTexfield.currencyStringToDouble())")

        if let client = clientTexfield.text, let date = selectedDate, let start = selectedStartTime, let end = selectedEndTime, let rate = payRateTexfield.currencyStringToDouble() {
            let workday = WorkdayItem(context: databaseContext)
            workday.clientName = client
            workday.date = date
            workday.location = locationTexfield.text
            workday.startTime = start
            workday.endTIme = end
            workday.lunchBreak = 0
            workday.payRate = rate
            workday.mileage = 0
            workday.workDescription = descriptionTexfield.text
            workday.isFinalized = true
            return saveWorkday()
        } else {
            return false
        }
    }
    
    func createDraftWorkday() -> Bool {
        if let client = clientTexfield.text {
            let workday = WorkdayItem(context: databaseContext)
            workday.clientName = client
            workday.date = selectedDate
            workday.location = locationTexfield.text
            workday.startTime = selectedStartTime
            workday.endTIme = selectedEndTime
            workday.lunchBreak = 0
            workday.payRate = payRateTexfield.currencyStringToDouble() ?? 0
            workday.mileage = 0
            workday.workDescription = descriptionTexfield.text
            workday.isFinalized = false
            return saveWorkday()
        } else {
            return false
        }
    }
    
    func showAlertDialog() {
        // Create a new alert
        let dialogMessage = UIAlertController(title: "Missing Information", message: "Please fill in all required fields", preferredStyle: .alert)
        
        let dismissButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            dialogMessage.dismiss(animated: true)
        })
        dialogMessage.addAction(dismissButton)
        // Present alert to user
        self.present(dialogMessage, animated: true, completion: nil)
    }


    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if createWorkday() {
            dismiss(animated: true)
        } else {
            showAlertDialog()
        }
    }
    @IBAction func saveDraftButtonPressed(_ sender: UIBarButtonItem) {
        if createDraftWorkday() {
            dismiss(animated: true)
        }
    }
    
}

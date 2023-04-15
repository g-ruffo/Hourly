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
        datePicker.addTarget(self, action: #selector(dateValueChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        dateTexfield.inputView = datePicker
        dateTexfield.text = Date().formatDateToString()
    }
    
    func setupTimePickers() {
        startTimePicker.datePickerMode = .time
        endTimePicker.datePickerMode = .time
        startTimePicker.addTarget(self, action: #selector(startTimeValueChange(datePicker:)), for: UIControl.Event.valueChanged)
        endTimePicker.addTarget(self, action: #selector(endTimeValueChange(datePicker:)), for: UIControl.Event.valueChanged)
        startTimePicker.frame.size = CGSize(width: 0, height: 300)
        endTimePicker.frame.size = CGSize(width: 0, height: 300)
        startTimePicker.preferredDatePickerStyle = .wheels
        endTimePicker.preferredDatePickerStyle = .wheels
        startTimeTexfield.inputView = startTimePicker
        endTimeTexfield.inputView = endTimePicker
    }
    
    @objc func dateValueChange(datePicker: UIDatePicker) {
        dateTexfield.text = datePicker.date.formatDateToString()
        selectedDate = datePicker.date
    }
    
    @objc func startTimeValueChange(datePicker: UIDatePicker) {
        startTimeTexfield.text = startTimePicker.date.formatTimeToString()
        selectedStartTime = datePicker.date
    }
    
    @objc func endTimeValueChange(datePicker: UIDatePicker) {
        endTimeTexfield.text = endTimePicker.date.formatTimeToString()
        selectedEndTime = datePicker.date
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
        if let client = clientTexfield.text, let date = selectedDate, let start = selectedStartTime, let end = selectedEndTime, let rate = payRateTexfield.currencyStringToDouble() {
            var workday = WorkdayItem(context: databaseContext)
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
            var workday = WorkdayItem(context: databaseContext)
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


    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if createWorkday() {
            dismiss(animated: true)
        }
    }
    @IBAction func saveDraftButtonPressed(_ sender: UIBarButtonItem) {
        if createDraftWorkday() {
            dismiss(animated: true)
        }
    }
    
}

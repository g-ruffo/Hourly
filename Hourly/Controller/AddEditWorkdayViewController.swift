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
    
    @IBOutlet weak var deleteClearButtonItem: UIBarButtonItem!
    
    private let datePicker = UIDatePicker()
    private let startTimePicker = UIDatePicker()
    private let endTimePicker = UIDatePicker()
    private var selectedDate: Date?
    private var selectedStartTime: Date?
    private var selectedEndTime: Date?
    
    var workdayEdit: WorkdayItem?
    
    private var manager = AddEditClientManager()

    let defaults = UserDefaults.standard
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        payRateTexfield.delegate = self
        setupDatePicker()
        setupTimePickers()
        checkForEdit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        checkUserDefaults()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateUserDefaults()
        print("viewWillDisappear")
    }
    
    func updateUserDefaults(clearValues: Bool = false) {
        if workdayEdit == nil && !clearValues {
            print("updateUserDefaults nil false")

            defaults.set(clientTexfield.text, forKey: K.UserDefaultsKey.client)
            defaults.set(selectedDate, forKey: K.UserDefaultsKey.date)
            defaults.set(locationTexfield.text, forKey: K.UserDefaultsKey.location)
            defaults.set(selectedStartTime, forKey: K.UserDefaultsKey.start)
            defaults.set(selectedEndTime, forKey: K.UserDefaultsKey.end)
            defaults.set(lunchTexfield.text, forKey: K.UserDefaultsKey.lunch)
            defaults.set(payRateTexfield.text, forKey: K.UserDefaultsKey.rate)
            defaults.set(mileageTexfield.text, forKey: K.UserDefaultsKey.mileage)
            defaults.set(descriptionTexfield.text, forKey: K.UserDefaultsKey.description)
        } else if workdayEdit == nil && clearValues {
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    func checkUserDefaults() {
        if workdayEdit == nil {
            print("checkUserDefaults nil")

            clientTexfield.text = defaults.string(forKey: K.UserDefaultsKey.client)
            selectedDate = defaults.object(forKey: K.UserDefaultsKey.date) as? Date
            locationTexfield.text = defaults.string(forKey: K.UserDefaultsKey.location)
            selectedStartTime = defaults.object(forKey: K.UserDefaultsKey.start) as? Date
            selectedEndTime = defaults.object(forKey: K.UserDefaultsKey.end) as? Date
            lunchTexfield.text = defaults.string(forKey: K.UserDefaultsKey.lunch)
            payRateTexfield.text = defaults.string(forKey: K.UserDefaultsKey.rate)
            mileageTexfield.text = defaults.string(forKey: K.UserDefaultsKey.mileage)
            descriptionTexfield.text = defaults.string(forKey: K.UserDefaultsKey.description)
        }
    }
    
    func checkForEdit() {
        if let workday = workdayEdit {
            title = "Edit Workday"
            clientTexfield.text = workday.clientName
            locationTexfield.text = workday.location
            payRateTexfield.text = "$\(workday.payRate)"
            lunchTexfield.text = String(workday.lunchBreak)
            mileageTexfield.text = String(workday.mileage)
            descriptionTexfield.text = workday.workDescription
            selectedDate = workday.date
            dateTexfield.text = datePicker.date.formatDateToString()
            selectedStartTime = workday.startTime
            startTimeTexfield.text = startTimePicker.date.formatTimeToString()
            selectedEndTime = workday.endTIme
            endTimeTexfield.text = endTimePicker.date.formatTimeToString()
        } else {
            title = "Add Worday"
            selectedDate = Date().zeroSeconds
            dateTexfield.text = Date().formatDateToString()
        }
    }
    
    func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateValueChange), for: .valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        dateTexfield.inputView = datePicker
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
            dismiss(animated: true) {
                self.updateUserDefaults(clearValues: true)
            }
        } else {
            showAlertDialog()
        }
    }
    @IBAction func saveDraftButtonPressed(_ sender: UIBarButtonItem) {
        if createDraftWorkday() {
            dismiss(animated: true) {
                self.updateUserDefaults(clearValues: true)
            }
        }
    }
    
    @IBAction func deleteClearButtonPressed(_ sender: UIBarButtonItem) {
        updateUserDefaults(clearValues: true)
        checkUserDefaults()
    }
    
}

extension AddEditWorkdayViewController: AddEditClientManagerDelegate {
    func didUpdateCurrencyText(_ addEditClientManager: AddEditClientManager, newCurrencyValue: String?) {
        payRateTexfield.text = newCurrencyValue
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        manager.validateCurrencyInput(string: string)
    }
}

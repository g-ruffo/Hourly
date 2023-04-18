//
//  WorkdayViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit
import CoreData

class AddEditWorkdayViewController: UIViewController {

    @IBOutlet weak var clientTextField: ClientSearchTextField!
    @IBOutlet weak var dateTexfield: UITextField!
    @IBOutlet weak var locationTexfield: UITextField!
    @IBOutlet weak var startTimeTexfield: UITextField!
    @IBOutlet weak var endTimeTexfield: UITextField!
    @IBOutlet weak var lunchTexfield: UITextField!
    @IBOutlet weak var payRateTexfield: UITextField!
    @IBOutlet weak var mileageTexfield: UITextField!
    @IBOutlet weak var descriptionTexfield: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIButton!
    
    private let datePicker = UIDatePicker()
    private let startTimePicker = UIDatePicker()
    private let endTimePicker = UIDatePicker()
    private let lunchPicker = UIPickerView()
    private let mileagePicker = UIPickerView()
    private var selectedDate: Date? {
        didSet { if let value = selectedDate { dateTexfield.text = value.formatDateToString() } }
    }
    private var selectedStartTime: Date? {
        didSet { if let value = selectedStartTime { startTimeTexfield.text = value.formatTimeToString() } }
    }
    private var selectedEndTime: Date? {
        didSet { if let value = selectedEndTime { endTimeTexfield.text = value.formatTimeToString() } }
    }
    private var selectedLunchTime: Int? {
        didSet { if let value = selectedLunchTime, value > 0 { lunchTexfield.text = "\(value) min" } }
    }
    private var selectedMileage: Int? {
        didSet { if let value = selectedMileage, value > 0 { mileageTexfield.text = "\(value) km" } }
    }

    
    var workdayEdit: WorkdayItem?
    private var selectedClient: ClientItem? {
        didSet {
            if let value = selectedClient {
                payRateTexfield.text = "$\(value.payRate)"
                locationTexfield.text = value.address
                clientTextField.backgroundColor = .clear
                payRateTexfield.backgroundColor = .clear
                locationTexfield.backgroundColor = .clear
            } else {
                payRateTexfield.text = nil
                locationTexfield.text = nil
                clientTextField.backgroundColor = .white
                payRateTexfield.backgroundColor = .white
                locationTexfield.backgroundColor = .white
            }
        }
    }
    private var selectedClientID: NSManagedObjectID? {
        didSet {
            if let id = selectedClientID {
                if selectedClient == nil {
                    do {
                        selectedClient = try databaseContext.existingObject(with: id) as? ClientItem
                    } catch {
                            fatalError(error.localizedDescription)
                    }
                }
            } else {
                selectedClient = nil
            }
        }
    }
    
    private var manager = AddEditWorkdayManager()
        
    private let lunchArray = [5, 10, 15, 20, 30, 40, 45, 60, 90, 120]
    private let mileageNumbers = [10,10,10]
    private var mileageDigits = [0,0,0]

    private let defaults = UserDefaults.standard
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var completedSave: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        payRateTexfield.delegate = self
        lunchPicker.delegate = self
        lunchPicker.dataSource = self
        mileagePicker.delegate = self
        mileagePicker.dataSource = self
        clientTextField.searchDelegate = self
        setupLunchMileagePicker()
        setupDatePicker()
        setupTimePickers()
        checkForEdit()
        setupMenuItems()
        saveButton.tintColor = UIColor("#F1C40F")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        checkUserDefaults()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateUserDefaults()
    }
    
    func setupMenuItems() {
        let menuHandler: UIActionHandler = { action in
            switch action.title {
            case "Save as Draft":
                if self.createDraftWorkday() {
                    self.dismiss(animated: true) {
                        self.completedSave = true
                        self.updateUserDefaults(clearValues: true)
                        NotificationCenter.default.post(name: K.NotificationKeys.updateWorkdaysNotification, object: nil)
                }
            }
            case "Clear":
                self.updateUserDefaults(clearValues: true)
                self.checkUserDefaults()
                
            case "Delete":
                self.showDeleteAlertDialog()
            default: print("Menu Handler Defaulted")
            }
        }
        
        let barButtonMenu = UIMenu(title: "", children: [
            UIAction(title: NSLocalizedString("Save as Draft", comment: ""), image: UIImage(systemName: "square.and.arrow.down"), handler: menuHandler),
            UIAction(title: NSLocalizedString(workdayEdit == nil ? "Clear" : "Delete", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive, handler: menuHandler)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis"), primaryAction: nil, menu: barButtonMenu)
    }
    
    func updateUserDefaults(clearValues: Bool = false) {
        if workdayEdit == nil && !clearValues && !completedSave {
            defaults.set(clientTextField.text, forKey: K.UserDefaultsKey.clientName)
            defaults.set(selectedDate, forKey: K.UserDefaultsKey.date)
            defaults.set(locationTexfield.text, forKey: K.UserDefaultsKey.location)
            defaults.set(selectedStartTime, forKey: K.UserDefaultsKey.start)
            defaults.set(selectedEndTime, forKey: K.UserDefaultsKey.end)
            defaults.set(selectedLunchTime, forKey: K.UserDefaultsKey.lunch)
            defaults.set(payRateTexfield.text, forKey: K.UserDefaultsKey.rate)
            defaults.set(selectedMileage, forKey: K.UserDefaultsKey.mileage)
            defaults.set(descriptionTexfield.text, forKey: K.UserDefaultsKey.description)
            defaults.set(selectedClientID?.uriRepresentation(), forKey: K.UserDefaultsKey.client)
        } else if workdayEdit == nil && clearValues {
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    func checkUserDefaults() {
        if workdayEdit == nil {
            clientTextField.text = defaults.string(forKey: K.UserDefaultsKey.clientName)
            locationTexfield.text = defaults.string(forKey: K.UserDefaultsKey.location)
            selectedStartTime = defaults.object(forKey: K.UserDefaultsKey.start) as? Date
            selectedEndTime = defaults.object(forKey: K.UserDefaultsKey.end) as? Date
            selectedLunchTime = defaults.integer(forKey: K.UserDefaultsKey.lunch)
            payRateTexfield.text = defaults.string(forKey: K.UserDefaultsKey.rate)
            selectedMileage = defaults.integer(forKey: K.UserDefaultsKey.mileage)
            descriptionTexfield.text = defaults.string(forKey: K.UserDefaultsKey.description)
            if let url = defaults.url(forKey: K.UserDefaultsKey.client),
               let objectId = databaseContext.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: url) {
                selectedClientID = objectId
            }
            if let date = defaults.object(forKey: K.UserDefaultsKey.date) as? Date {
                selectedDate = date
            }

        }
    }
    
    func checkForEdit() {
        if let workday = workdayEdit {
            title = "Edit Workday"
            clientTextField.text = workday.clientName
            locationTexfield.text = workday.location
            payRateTexfield.text = "$\(workday.payRate)"
            selectedLunchTime = Int(workday.lunchBreak)
            selectedMileage = Int(workday.mileage)
            descriptionTexfield.text = workday.workDescription
            selectedDate = workday.date
            selectedStartTime = workday.startTime
            selectedEndTime = workday.endTIme
        } else {
            title = "Add Worday"
            selectedDate = Date().zeroSeconds
        }
    }
    
    func setupLunchMileagePicker() {
        lunchTexfield.inputView = lunchPicker
        mileageTexfield.inputView = mileagePicker
        lunchPicker.tag = 1
        mileagePicker.tag = 2
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
        selectedDate = datePicker.date.zeroSeconds
    }
    
    @objc func startTimeValueChange(_ datePicker: UIDatePicker) {
        selectedStartTime = datePicker.date.zeroSeconds
    }
    
    @objc func endTimeValueChange(_ datePicker: UIDatePicker) {
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
    
    func deleteWorkdayFromDatabase() {
        if let workday = workdayEdit {
            databaseContext.delete(workday)
            if saveWorkday() {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func createUpdateWorkday() -> Bool {
        if let client = clientTextField.text, let date = selectedDate, let start = selectedStartTime, let end = selectedEndTime, let rate = payRateTexfield.currencyStringToDouble() {
            var workday: WorkdayItem
            if let day = workdayEdit {
                workday = day
                print("Is Updating workday")
            } else {
                print("Creating new workday")
                workday = WorkdayItem(context: databaseContext)
            }
            workday.clientName = client
            workday.date = date
            workday.location = locationTexfield.text
            workday.startTime = start
            workday.endTIme = end
            workday.lunchBreak = Int16(selectedLunchTime ?? 0)
            workday.payRate = rate
            workday.mileage = Int32(selectedMileage ?? 0)
            workday.workDescription = descriptionTexfield.text
            workday.earnings = manager.calculateEarnings(startTime: start, endTime: end, lunchTime: selectedLunchTime, payRate: rate)
            workday.isFinalized = true
            if let client = selectedClient {
                workday.client = client
            }
            return saveWorkday()
        } else {
            return false
        }
    }
    
    func createDraftWorkday() -> Bool {
        if let client = clientTextField.text {
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
            if let client = selectedClient {
                workday.client = client
            }
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
    
    func showDeleteAlertDialog() {
        // Create a new alert
        let dialogMessage = UIAlertController(title: "Are You Sure?", message: "Deleting this workday can't be undone, are you sure you would like to proceed?", preferredStyle: .alert)
        
        let dismissButton = UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
            dialogMessage.dismiss(animated: true)
        })
        let confirmButton = UIAlertAction(title: "DELETE!", style: .destructive, handler: { (action) -> Void in
            self.deleteWorkdayFromDatabase()
            dialogMessage.dismiss(animated: true)
        })
        
        dialogMessage.addAction(dismissButton)
        dialogMessage.addAction(confirmButton)
        // Present alert to user
        self.present(dialogMessage, animated: true, completion: nil)
    }


    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if createUpdateWorkday() {
            self.completedSave = true
            self.updateUserDefaults(clearValues: true)
            NotificationCenter.default.post(name: K.NotificationKeys.updateWorkdaysNotification, object: nil)
            
            if workdayEdit == nil {
                dismiss(animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
        } else {
            showAlertDialog()
        }
    }
}

//MARK: - AddEditClientManagerDelegate
extension AddEditWorkdayViewController: AddEditWorkdayManagerDelegate {
    func didUpdateCurrencyText(_ addEditWorkdayManager: AddEditWorkdayManager, newCurrencyValue: String?) {
        payRateTexfield.text = newCurrencyValue
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        manager.validateCurrencyInput(string: string)
    }
}

//MARK: - UIPickerViewDelegate
extension AddEditWorkdayViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1: selectedLunchTime = lunchArray[row]
        case 2: mileageDigits[component] = row
            selectedMileage = Int("\(mileageDigits[0])\(mileageDigits[1])\(mileageDigits[2])")
        default: print("Error getting UIPicker")
        }
    }
}

//MARK: - UIPickerViewDataSource
extension AddEditWorkdayViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 1: return 1
        case 2: return 3
        default:
            print("Error getting UIPicker")
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1: return lunchArray.count
        case 2: return mileageNumbers[component]
        default:
            print("Error getting UIPicker")
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1: return "\(lunchArray[row]) min"
        case 2: return String(row)
        default: return "Error getting UIPicker"
        }
    }
}

//MARK: - ClientSearchDelegate
extension AddEditWorkdayViewController: ClientSearchDelegate {
    func selectedExistingClient(_ clientSearchTextField: ClientSearchTextField, clientID: NSManagedObjectID?) {
        self.selectedClientID = clientID
    }
}

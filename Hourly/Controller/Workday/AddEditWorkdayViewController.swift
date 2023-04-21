//
//  WorkdayViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit
import CoreData
import PhotosUI

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
    
    private var manager = AddEditWorkdayManager()
    
    private let lunchArray = [5, 10, 15, 20, 30, 40, 45, 60, 90, 120]
    private let mileageNumbers = [10,10,10]
    private var mileageDigits = [0,0,0]
    
    private let defaults = UserDefaults.standard
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
    private var completedSave: Bool = false
    
    private var savedPhotos: Array<PhotoItem> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        payRateTexfield.delegate = self
        lunchPicker.delegate = self
        lunchPicker.dataSource = self
        mileagePicker.delegate = self
        mileagePicker.dataSource = self
        clientTextField.searchDelegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        setupLunchMileagePicker()
        setupDatePicker()
        setupTimePickers()
        checkForEdit()
        setupMenuItems()
        saveButton.tintColor = UIColor("#F1C40F")
        createCollectionView()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkUserDefaults()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateUserDefaults()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.editPhotoCollectionNav {
            let destinationVC = segue.destination as! PhotoViewController
            destinationVC.photos = savedPhotos
            destinationVC.startingRow = sender as? Int
            destinationVC.allowEditing = true
        }
    }
    
    func createCollectionView() {
        collectionView.register(PhotoCell.nib(), forCellWithReuseIdentifier: K.Cell.photoCell)
    }

    
    func setupMenuItems() {
        let menuHandler: UIActionHandler = { action in
            switch action.title {
            case "Save as Draft":
                if self.createDraftWorkday() {
                    print("saved draft")
                    if self.workdayEdit != nil {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.dismiss(animated: true) {
                            self.completedSave = true
                            self.updateUserDefaults(clearValues: true)
                            NotificationCenter.default.post(name: K.NotificationKeys.updateWorkdaysNotification, object: nil)
                        }
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
            selectedClient = workday.client
            clientTextField.text = workday.clientName
            locationTexfield.text = workday.location
            payRateTexfield.text = "$\(workday.payRate)"
            selectedLunchTime = Int(workday.lunchBreak)
            selectedMileage = Int(workday.mileage)
            descriptionTexfield.text = workday.workDescription
            selectedDate = workday.date
            selectedStartTime = workday.startTime
            selectedEndTime = workday.endTime
            savedPhotos = workday.photos?.allObjects as? Array<PhotoItem> ?? []
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
        if let client = clientTextField.text,
           let date = selectedDate,
           let start = selectedStartTime,
           let end = selectedEndTime,
           let rate = payRateTexfield.currencyStringToDouble() {
            
            var workday: WorkdayItem
            if let day = workdayEdit { workday = day }
            else { workday = WorkdayItem(context: databaseContext) }
            
            let adjustedStart = manager.setStartTimeDate(startTime: start, date: date)
            let adjustedEnd = manager.setEndTimeDate(startTime: adjustedStart, endTime: end, date: date)
            workday.clientName = client
            workday.date = date
            workday.location = locationTexfield.text
            workday.startTime = adjustedStart
            workday.endTime = adjustedEnd
            workday.lunchBreak = Int16(selectedLunchTime ?? 0)
            workday.payRate = rate
            workday.mileage = Int32(selectedMileage ?? 0)
            workday.workDescription = descriptionTexfield.text
            workday.earnings = manager.calculateEarnings(startTime: adjustedStart, endTime: adjustedEnd, lunchTime: selectedLunchTime, payRate: rate)
            workday.isFinalized = true
            workday.client = selectedClient
            createPhotoItems(workday: workday)
            return saveWorkday()
        } else {
            return false
        }
    }
    
    func createDraftWorkday() -> Bool {
        if let client = clientTextField.text, let date = selectedDate {
            
            var workday: WorkdayItem
            if let day = workdayEdit { workday = day }
            else { workday = WorkdayItem(context: databaseContext) }
            
            let start = selectedStartTime
            let end = selectedEndTime
            
            let adjustedStart = manager.setStartTimeDate(startTime: start, date: date)
            let adjustedEnd = manager.setEndTimeDate(startTime: adjustedStart, endTime: end, date: date)
            if let rate = payRateTexfield.currencyStringToDouble() {
                workday.payRate = rate
                workday.earnings = manager.calculateEarnings(startTime: adjustedStart, endTime: adjustedEnd, lunchTime: selectedLunchTime, payRate: rate)
            }
            
            workday.clientName = client
            workday.date = date
            workday.location = locationTexfield.text
            workday.startTime = adjustedStart
            workday.endTime = adjustedEnd
            workday.lunchBreak = Int16(selectedLunchTime ?? 0)
            workday.mileage = Int32(selectedMileage ?? 0)
            workday.workDescription = descriptionTexfield.text
            workday.isFinalized = false
            workday.client = selectedClient
            createPhotoItems(workday: workday)
            return saveWorkday()
        } else {
            return false
        }
    }
    
    func createPhotoItems(workday: WorkdayItem) {
            for photo in savedPhotos {
                photo.workingDay = workday
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
    
    func createPhotoPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 10
        config.filter = PHPickerFilter.images
        let pickerVC = PHPickerViewController(configuration: config)
        pickerVC.delegate = self
        present(pickerVC, animated: true)
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

//MARK: - PHPickerViewControllerDelegate
extension AddEditWorkdayViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let group = DispatchGroup()
        results.forEach { result in
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                defer {
                    group.leave()
                }
                guard let image = reading as? UIImage, error == nil else {
                    print("didFinishPicking error = \(String(describing: error?.localizedDescription))")
                    return
                }
                
                let jpegImage = image.jpegData(compressionQuality: 1.0)
                let photoItem = PhotoItem(context: self!.databaseContext)
                photoItem.image = jpegImage
                photoItem.imageDescription = "Date: \(self!.selectedDate!.formatDateToString())"
                self?.savedPhotos.append(photoItem)
            }
        }
        group.notify(queue: .main) {
            self.collectionView.reloadData()
        }
    }
}

//MARK: - UICollectionViewDelegate
extension AddEditWorkdayViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.row == 0 {
            createPhotoPicker()
        } else {
            performSegue(withIdentifier: K.Segue.editPhotoCollectionNav, sender: indexPath.row - 1)
        }
    }
}

//MARK: - UICollectionViewDataSource
extension AddEditWorkdayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPhotos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Cell.photoCell, for: indexPath) as! PhotoCell

        if indexPath.row == 0 {
            let insets = UIEdgeInsets(top: -35, left: -35, bottom: -35, right: -35)
            let image = UIImage(systemName: "plus")!
            cell.configure(with: image.withAlignmentRectInsets(insets))
            cell.imageView.tintColor = UIColor(named: "PrimaryBlueDark")
            
        } else {
            if let image = UIImage(data: savedPhotos[indexPath.row - 1].image!) {
                cell.imageView.image = image
            } else {
                cell.imageView.image = UIImage(systemName: "externaldrive.badge.questionmark")
            }
        }
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension AddEditWorkdayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
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

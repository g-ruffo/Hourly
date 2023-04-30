//
//  WorkdayViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit
import CoreData
import PhotosUI

enum PickerTags: Int {
    case date, startTime, endTime
}
class AddEditWorkdayViewController: UIViewController {
    // MARK: - Variables
    @IBOutlet weak var clientTextField: ClientSearchTextField!
    @IBOutlet weak var locationTexfield: FloatingLabelTextField!
    @IBOutlet weak var lunchTexfield: FloatingLabelTextField!
    @IBOutlet weak var payRateTexfield: FloatingLabelTextField!
    @IBOutlet weak var mileageTexfield: FloatingLabelTextField!
    @IBOutlet weak var descriptionTexfield: FloatingLabelTextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet weak var endTimeDatePicker: UIDatePicker!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    private let lunchPicker = UIPickerView()
    private let mileagePicker = UIPickerView()
    private var selectedLunchTimeMinutes: Int? {
        didSet { if let value = selectedLunchTimeMinutes, value > 0 { lunchTexfield.text = "\(value) min" } }
    }
    private var selectedMileage: Int? {
        didSet { if let value = selectedMileage, value > 0 { mileageTexfield.text = "\(value) km" } }
    }
    private var manager = AddEditWorkdayManager()
    private let coreDataService = CoreDataService()
    // Selection options in minutes.
    private let lunchArray = [5, 10, 15, 20, 30, 40, 45, 60, 90, 120]
    // Mileage wheels limit.
    private let mileageNumbers = [10, 10, 10]
    // The users set mileage value.
    private var mileageDigits = [0, 0, 0]
    private let defaults = UserDefaults.standard
    private var isEditingWorkday: Bool = false
    private var completedSave: Bool = false
    private var photos: Array<PhotoItem> = []
    var editWorkdayId: NSManagedObjectID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set delegates and data source
        manager.delegate = self
        payRateTexfield.delegate = self
        lunchPicker.delegate = self
        lunchPicker.dataSource = self
        mileagePicker.delegate = self
        mileagePicker.dataSource = self
        clientTextField.searchDelegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        coreDataService.delegate = self
        setupLunchMileagePicker()
        setupDatePicker()
        checkForEdit()
        setupMenuItems()
        // Set save button background colour.
        saveButton.tintColor = UIColor("#F1C40F")
        createCollectionView()
        // Set the navigation bar title colour to black.
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        // Set the scroll views bottom anchor to follow the keyboard.
        scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        // Automatically hide spinner when stopped.
        loadingSpinner.hidesWhenStopped = true
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
        if segue.identifier == K.Navigation.editPhotoCollectionNav {
            let destinationVC = segue.destination as? PhotoViewController
            // Pass the index of the selected photo to the destination view controller.
            destinationVC?.startingRow = sender as? Int
            // Set the destination view controllers variable to allow editing.
            destinationVC?.allowEditing = true
            // Pass the current service class reference to the destination view controller.
            destinationVC?.coreDataService = coreDataService
            // Set the destination view controllers delegate to self to be notified of changes to the photos.
            destinationVC?.delegate = self
        }
    }
    func checkForEdit() {
        // If the workday id is not nil the user is editing an existing object.
        if let id = editWorkdayId {
            coreDataService.getWorkdayFromObjectId(id)
            isEditingWorkday = true
        } else { isEditingWorkday = false}
    }
    func createCollectionView() {
        collectionView.register(PhotoCell.nib(), forCellWithReuseIdentifier: K.Cell.photoCell)
        collectionView.register(AddPhotoCell.nib(), forCellWithReuseIdentifier: K.Cell.addPhotoCell)
    }
    func setupMenuItems() {
        // Set the appropriate navigation bar title.
        title = isEditingWorkday ? "Edit Workday" : "Add Worday"
        let menuHandler: UIActionHandler = { action in
            switch action.title {
            case "Save as Draft":
                if self.createUpdateWorkday(isDraft: true) {
                    NotificationCenter.default.post(name: K.NotificationKeys.updateWorkdaysNotification, object: nil)
                    if self.isEditingWorkday {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.dismiss(animated: true) {
                            self.completedSave = true
                            self.updateUserDefaults(clearValues: true)
                        }
                    }
                }
            case "Clear":
                self.updateUserDefaults(clearValues: true)
                self.checkUserDefaults()
                self.startTimeDatePicker.setDate(Date().startOfDay, animated: true)
            case "Delete":
                self.showDeleteAlertDialog()
            default: print("Menu Handler Defaulted")
            }
        }
        let barButtonMenu = UIMenu(title: "", children: [
            UIAction(title: NSLocalizedString("Save as Draft", comment: ""),
                     image: UIImage(systemName: "square.and.arrow.down"),
                     handler: menuHandler),
            UIAction(title: NSLocalizedString(isEditingWorkday ? "Delete" : "Clear", comment: ""),
                     image: UIImage(systemName: "trash"),
                     attributes: .destructive,
                     handler: menuHandler)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil,
                                                            image: UIImage(systemName: "ellipsis"),
                                                            primaryAction: nil,
                                                            menu: barButtonMenu)
    }
    func updateUserDefaults(clearValues: Bool = false) {
        if !isEditingWorkday && !clearValues && !completedSave {
            defaults.set(clientTextField.text, forKey: K.UserDefaultsKey.clientName)
            defaults.set(datePicker.date, forKey: K.UserDefaultsKey.date)
            defaults.set(locationTexfield.text, forKey: K.UserDefaultsKey.location)
            defaults.set(startTimeDatePicker.date, forKey: K.UserDefaultsKey.start)
            defaults.set(endTimeDatePicker.date, forKey: K.UserDefaultsKey.end)
            defaults.set(selectedLunchTimeMinutes, forKey: K.UserDefaultsKey.lunch)
            defaults.set(payRateTexfield.text, forKey: K.UserDefaultsKey.rate)
            defaults.set(selectedMileage, forKey: K.UserDefaultsKey.mileage)
            defaults.set(descriptionTexfield.text, forKey: K.UserDefaultsKey.description)
            defaults.set(coreDataService.getWorkdayClientID(), forKey: K.UserDefaultsKey.client)
        } else if !isEditingWorkday && clearValues {
            let dictionary = defaults.dictionaryRepresentation()
            self.coreDataService.getClientFromID(nil)
            dictionary.keys.forEach { key in
                defaults.removeObject(forKey: key)
            }
        }
    }
    func checkUserDefaults() {
        if !isEditingWorkday {
            clientTextField.text = defaults.string(forKey: K.UserDefaultsKey.clientName)
            locationTexfield.text = defaults.string(forKey: K.UserDefaultsKey.location)
            startTimeDatePicker.date = defaults.object(forKey: K.UserDefaultsKey.start) as? Date ?? Date()
            endTimeDatePicker.date = defaults.object(forKey: K.UserDefaultsKey.end) as? Date ?? Date()
            selectedLunchTimeMinutes = defaults.integer(forKey: K.UserDefaultsKey.lunch)
            payRateTexfield.text = defaults.string(forKey: K.UserDefaultsKey.rate)
            selectedMileage = defaults.integer(forKey: K.UserDefaultsKey.mileage)
            descriptionTexfield.text = defaults.string(forKey: K.UserDefaultsKey.description)
            if let url = defaults.url(forKey: K.UserDefaultsKey.client) {
                coreDataService.getClientFromURL(url: url)
            }
            if let date = defaults.object(forKey: K.UserDefaultsKey.date) as? Date {
                datePicker.date = date
            }
        }
    }
    func setupLunchMileagePicker() {
        lunchTexfield.inputView = lunchPicker
        mileageTexfield.inputView = mileagePicker
        lunchPicker.tag = 1
        mileagePicker.tag = 2
    }
    func setupDatePicker() {
        datePicker.tag = PickerTags.date.rawValue
        startTimeDatePicker.tag = PickerTags.startTime.rawValue
        endTimeDatePicker.tag = PickerTags.endTime.rawValue
        startTimeDatePicker.setDate(Date().startOfDay, animated: true)
        datePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        startTimeDatePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        endTimeDatePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
    }
    @objc func datePickerChanged(picker: UIDatePicker) {
        switch picker.tag {
        case PickerTags.date.rawValue: datePicker.date = datePicker.date.zeroSeconds
            presentedViewController?.dismiss(animated: true, completion: nil)
        case PickerTags.startTime.rawValue: startTimeDatePicker.date = startTimeDatePicker.date.zeroSeconds
        case PickerTags.endTime.rawValue: endTimeDatePicker.date = endTimeDatePicker.date.zeroSeconds
        default: print("Error unknown picker selected")
        }
    }
    func createUpdateWorkday(isDraft: Bool = false) -> Bool {
        if let client = clientTextField.text {
            // Check if client name is empty.
            guard !client.trimmingCharacters(in: .whitespaces).isEmpty else {
                showAlertDialog(title: S.alertTitleMissingInfo.localized,
                                message: S.alertMessageMissingInfo.localized)
                return false
            }
            let workDate = datePicker.date.startOfDay
            let adjustedStart = manager.setStartTimeDate(startTime: startTimeDatePicker.date, date: workDate)
            let adjustedEnd = manager.setEndTimeDate(startTime: adjustedStart,
                                                     endTime: endTimeDatePicker.date,
                                                     date: workDate)
            let lunch = Int32(selectedLunchTimeMinutes ?? 0)
            let rate = payRateTexfield.currencyStringToDouble() ?? 0.00
            let mileage = Int32(selectedMileage ?? 0)
            let location = locationTexfield.text
            let workDescription = descriptionTexfield.text
            let earnings = manager.calculateEarnings(startTime: adjustedStart,
                                                     endTime: adjustedEnd,
                                                     lunchMinutes: selectedLunchTimeMinutes,
                                                     payRate: rate)
            let minutesWorked = manager.calculateTimeWorkedInMinutes(startTime: adjustedStart,
                                                                     endTime: adjustedEnd,
                                                                     lunchMinutes: selectedLunchTimeMinutes ?? 0)
            return coreDataService.createUpdateWorkday(
                clientName: client,
                date: workDate,
                start: adjustedStart,
                end: adjustedEnd,
                lunch: lunch,
                mileage: mileage,
                rate: rate,
                location: location,
                description: workDescription,
                timeWorked: minutesWorked,
                earnings: earnings,
                isDraft: isDraft
            )
        } else {
            return false
        }
    }
    func showAlertDialog(title: String, message: String) {
        // Create a new alert
        let dialogMessage = UIAlertController(title: title,
                                              message: message,
                                              preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: { (_) -> Void in
            dialogMessage.dismiss(animated: true)
        })
        dialogMessage.addAction(dismissButton)
        // Present alert to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    func showDeleteAlertDialog() {
        // Create a new alert
        let dialogMessage = UIAlertController(title: S.alertTitleDeleteConfirm.localized,
                                              message: S.alertMessageDeleteConfirm.localized, preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "No", style: .default, handler: { (_) -> Void in
            dialogMessage.dismiss(animated: true)
        })
        let confirmButton = UIAlertAction(title: "DELETE!", style: .destructive, handler: { (_) -> Void in
            dialogMessage.dismiss(animated: true)
            if self.coreDataService.deleteWorkday() { self.navigationController?.popViewController(animated: true) }
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
            if !isEditingWorkday {  dismiss(animated: true) }
            else { navigationController?.popViewController(animated: true) }
        } else {
            showAlertDialog(title: S.alertTitleMissingInfo.localized,
                            message: S.alertMessageMissingInfo.localized)
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
// MARK: - AddEditWorkdayManagerDelegate
extension AddEditWorkdayViewController: AddEditWorkdayManagerDelegate {
    func didUpdateCurrencyText(_ addEditWorkdayManager: AddEditWorkdayManager, newCurrencyValue: String?) {
        payRateTexfield.text = newCurrencyValue
    }
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        manager.validateCurrencyInput(string: string)
    }
}
// MARK: - PHPickerViewControllerDelegate
extension AddEditWorkdayViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        loadingSpinner.startAnimating()
        picker.dismiss(animated: true)
        let group = DispatchGroup()
        var jpegImages: Array<Data?> = []
        var convertingError: Error?
        results.forEach { result in
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                defer {
                    group.leave()
                }
                guard let image = reading as? UIImage, error == nil else {
                    print("didFinishPicking error = \(String(describing: error?.localizedDescription))")
                    convertingError = error
                    return
                }
                let jpegImage = image.jpegData(compressionQuality: 1.0)
                jpegImages.append(jpegImage)
            }
        }
        group.notify(queue: .main) {
            self.coreDataService.createPhotoItems(from: jpegImages)
            self.loadingSpinner.stopAnimating()
            if let _ = convertingError {
                self.showAlertDialog(title: S.alertTitleCantConvertPhoto.localized,
                                     message: S.alertMessageCantConvertPhoto.localized)
            }
        }
    }
}
// MARK: - UICollectionViewDelegate
extension AddEditWorkdayViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.item == photos.count {
            createPhotoPicker()
        } else {
            performSegue(withIdentifier: K.Navigation.editPhotoCollectionNav, sender: indexPath.row)
        }
    }
}
// MARK: - UICollectionViewDataSource
extension AddEditWorkdayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == photos.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Cell.addPhotoCell, for: indexPath) as! AddPhotoCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Cell.photoCell, for: indexPath) as! PhotoCell
            let imageData = photos[indexPath.row].image
            if let image = imageData {
                let uiImage = UIImage(data: image)
                cell.imageView.image = uiImage
            } else {
                cell.imageView.image = UIImage(systemName: "externaldrive.badge.questionmark")
            }
            return cell
        }
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension AddEditWorkdayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
// MARK: - UIPickerViewDelegate
extension AddEditWorkdayViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1: selectedLunchTimeMinutes = lunchArray[row]
        case 2: mileageDigits[component] = row
            selectedMileage = Int("\(mileageDigits[0])\(mileageDigits[1])\(mileageDigits[2])")
        default: print("Error getting UIPicker")
        }
    }
}
// MARK: - UIPickerViewDataSource
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
// MARK: - ClientSearchDelegate
extension AddEditWorkdayViewController: ClientSearchDelegate {
    func selectedExistingClient(_ clientSearchTextField: ClientSearchTextField, clientID: NSManagedObjectID?) {
        self.coreDataService.getClientFromID(clientID)
    }
}
// MARK: - PhotoCollectionDelegate
extension AddEditWorkdayViewController: PhotoCollectionDelegate {
    func photoHasBeenDeleted(_ photoViewController: PhotoViewController) {
        photos = coreDataService.workdayPhotos
        DispatchQueue.main.async { self.collectionView.reloadData() }
    }
}
// MARK: - CoreDataServiceDelegate
extension AddEditWorkdayViewController: CoreDataServiceDelegate {
    func loadedWorkday(_ coreDataService: CoreDataService, workdayItem: WorkdayItem?) {
        if let day = workdayItem {
            clientTextField.text = day.clientName
            locationTexfield.text = day.location
            payRateTexfield.text = "$\(day.payRate)"
            selectedLunchTimeMinutes = Int(day.lunchMinutes)
            selectedMileage = Int(day.mileage)
            descriptionTexfield.text = day.workDescription
            if let date = day.date { datePicker.date = date }
            if let start = day.startTime { startTimeDatePicker.date = start }
            if let end = day.endTime { endTimeDatePicker.date = end }
        }
    }
    func loadedClient(_ coreDataService: CoreDataService, clientItem: ClientItem?) {
        payRateTexfield.text = clientItem != nil ? "$\(clientItem!.payRate)" : nil
        locationTexfield.text = clientItem != nil ? clientItem!.address : nil
        clientTextField.backgroundColor = clientItem != nil ? .clear : .white
        payRateTexfield.backgroundColor = clientItem != nil ? .clear : .white
        locationTexfield.backgroundColor = clientItem != nil ? .clear : .white
    }
    func loadedPhotos(_ coreDataService: CoreDataService, photoItems: Array<PhotoItem>) {
        photos = photoItems
        DispatchQueue.main.async { self.collectionView.reloadData() }
    }
}

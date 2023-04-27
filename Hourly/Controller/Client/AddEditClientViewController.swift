//
//  AddEditClientViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-11.
//

import UIKit
import UIColorHexSwift
import CoreData

class AddEditClientViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var payRateTextField: UITextField!
    @IBOutlet weak var popUpButton: UIButton!
    
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    private let coreDataService = CoreDataService()
    
    private var selectedColour = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1).hexString()
    
    private var manager = AddEditClientManager()
    private var isEditingClient = false
    

    private let tagStringColours: Array<String> = [
        "#0096FF", "#941751", "#941100", "#FF9300", "#00F900", "#0433FF", "#FF2F92", "#FFFB00", "#942193", "#73FCD6", "#009193", "#FF2600", "#FF85FF", "#FFFC79"
    ]
    
    var editClientId: NSManagedObjectID?

    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataService.delegate = self
        manager.delegate = self
        payRateTextField.delegate = self
        checkForEdit()
        setupPopUpButton()
        saveButton.tintColor = UIColor("#F1C40F")
        
        companyNameTextField.addDoneButtonOnKeyboard()
        contactNameTextField.addDoneButtonOnKeyboard()
        phoneNumberTextField.addDoneButtonOnKeyboard()
        emailTextField.addDoneButtonOnKeyboard()
        addressTextField.addDoneButtonOnKeyboard()
        payRateTextField.addDoneButtonOnKeyboard()
    }
    
    func checkForEdit() {
        if let id = editClientId {
            coreDataService.getClientFromID(id)
            isEditingClient = true
        } else { isEditingClient = false }
        
        self.title = isEditingClient ? S.editClientTitle.localized : S.addClientTitle.localized
        deleteBarButton.isEnabled = isEditingClient
        deleteBarButton.tintColor = isEditingClient ? .red : .clear
    }
    
    func setupPopUpButton() {
        let initialImage = UIImage(systemName: "circle.fill")?.withTintColor(UIColor(selectedColour), renderingMode: .alwaysOriginal)
        popUpButton.setImage(initialImage, for: .normal)
        popUpButton.setTitle("Tag Colour", for: .normal)
        popUpButton.imageView?.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        popUpButton.layer.borderWidth = 1
        popUpButton.layer.cornerRadius = 8
        
        // Called when selection is made
        let optionClosure = {(action: UIAction) in
            self.popUpButton.setImage(action.image, for: .normal)
            self.selectedColour = action.discoverabilityTitle ?? "#0096FF"
                }

        var optionsArray = [UIAction]()

        for hex in tagStringColours {
            let image = UIImage(systemName: "circle.fill")?.withTintColor(UIColor(hex), renderingMode: .alwaysOriginal)
            
            // Create each action and insert the coloured image
            let action = UIAction(image: image, discoverabilityTitle: hex, state: .off, handler: optionClosure)

            // Add created action to action array
            optionsArray.append(action)
        
        }
                
                
        // set the state of first country in the array as ON
        optionsArray[0].state = .on

        // create an options menu
        let optionsMenu = UIMenu(options: .displayInline, children: optionsArray)
        
                
        // add everything to your button
        popUpButton.menu = optionsMenu

        // make sure the popup button shows the selected value
        popUpButton.changesSelectionAsPrimaryAction = true
        popUpButton.showsMenuAsPrimaryAction = true
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
        let dialogMessage = UIAlertController(title: "Are You Sure?", message: "Deleting this client can't be undone, are you sure you would like to proceed?", preferredStyle: .alert)
        
        let dismissButton = UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
            dialogMessage.dismiss(animated: true)
        })
        let confirmButton = UIAlertAction(title: "DELETE!", style: .destructive, handler: { (action) -> Void in
            dialogMessage.dismiss(animated: true)
            if self.coreDataService.deleteClient() { self.navigationController?.popViewController(animated: true) }
        })
        
        dialogMessage.addAction(dismissButton)
        dialogMessage.addAction(confirmButton)
        // Present alert to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func createUpdateClient() {
        guard let company = companyNameTextField.text else {
            showAlertDialog()
            return
        }
        let contact = contactNameTextField.text
        let phoneNumber = phoneNumberTextField.text
        let email = emailTextField.text
        let address = addressTextField.text
        let rate = payRateTextField.currencyStringToDouble() ?? 0
        let colour = selectedColour
        
        if coreDataService.createUpdateClient(companyName: company, contactName: contact, phone: phoneNumber, email: email, address: address, rate: rate, tagColour: colour) {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func saveClient() -> Bool { return coreDataService.saveToDatabase() }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if !companyNameTextField.isValid() {
            showAlertDialog()
        } else {
            createUpdateClient()
        }
    }
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        showDeleteAlertDialog()
        
    }
    
}
//MARK: - AddEditClientManagerDelegate
extension AddEditClientViewController: AddEditClientManagerDelegate {
    func didUpdateCurrencyText(_ addEditClientManager: AddEditClientManager, newCurrencyValue: String?) {
        payRateTextField.text = newCurrencyValue
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        manager.validateCurrencyInput(string: string)
    }
}

//MARK: - CoreDataServiceDelegate
extension AddEditClientViewController: CoreDataServiceDelegate {
    func loadedClient(_ coreDataService: CoreDataService, clientItem: ClientItem?) {
        if let client = clientItem {
            companyNameTextField.text = client.companyName
            contactNameTextField.text = client.contactName
            phoneNumberTextField.text = client.phoneNumber
            emailTextField.text = client.email
            addressTextField.text = client.address
            payRateTextField.text = client.payRate.convertToCurrency()
            if let colour = client.tagColor { selectedColour = colour }
        }
    }
}


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
    @IBOutlet weak var companyNameTextField: FloatingLabelTextField!
    @IBOutlet weak var contactNameTextField: FloatingLabelTextField!
    @IBOutlet weak var phoneNumberTextField: FloatingLabelTextField!
    @IBOutlet weak var emailTextField: FloatingLabelTextField!
    @IBOutlet weak var addressTextField: FloatingLabelTextField!
    @IBOutlet weak var payRateTextField: FloatingLabelTextField!
    
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    
    @IBOutlet weak var tagButton: ColourTagButton!
    @IBOutlet weak var stackView: UIStackView!
    private let coreDataService = CoreDataService()
    
    private var selectedColour = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1).hexString()
    
    private var manager = AddEditClientManager()
    private var isEditingClient = false
    
    var editClientId: NSManagedObjectID?

    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataService.delegate = self
        manager.delegate = self
        payRateTextField.delegate = self
        tagButton.delegate = self
        tagButton.selectedColour = selectedColour
        checkForEdit()
        saveButton.tintColor = UIColor("#F1C40F")
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

    func showAlertDialog() {
        // Create a new alert
        let dialogMessage = UIAlertController(title: S.alertTitleMissingInfo.localized,
                                              message: S.alertMessageMissingInfo.localized,
                                              preferredStyle: .alert)
        
        let dismissButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            dialogMessage.dismiss(animated: true)
        })
        dialogMessage.addAction(dismissButton)
        // Present alert to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func showDeleteAlertDialog() {
        // Create a new alert
        let dialogMessage = UIAlertController(title: S.alertTitleDeleteConfirm.localized,
                                              message: S.alertMessageDeleteConfirm.localized,
                                              preferredStyle: .alert)
        
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
            if let colour = client.tagColor {
                selectedColour = colour
                tagButton.selectedColour = colour
            }
        }
    }
}

//MARK: - ColourTagButtonDelegate
extension AddEditClientViewController: ColourTagButtonDelegate {
    func didUpdateColourTag(_ colourTagButton: ColourTagButton, hexString: String) {
        selectedColour = hexString
    }
}


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
    // MARK: - Variables
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var companyNameTextField: FloatingLabelTextField!
    @IBOutlet weak var contactNameTextField: FloatingLabelTextField!
    @IBOutlet weak var phoneNumberTextField: FloatingLabelTextField!
    @IBOutlet weak var emailTextField: FloatingLabelTextField!
    @IBOutlet weak var addressTextField: FloatingLabelTextField!
    @IBOutlet weak var payRateTextField: FloatingLabelTextField!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var tagButton: ColourTagButton!
    private let coreDataService = CoreDataService()
    private var selectedColour = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1).hexString()
    private var manager = AddEditClientManager()
    private var isEditingClient = false
    var editClientId: NSManagedObjectID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set delegates.
        coreDataService.delegate = self
        manager.delegate = self
        payRateTextField.delegate = self
        tagButton.delegate = self
        tagButton.selectedColour = selectedColour
        checkForEdit()
        // Set the save button background colour.
        saveButton.tintColor = UIColor("#F1C40F")
    }
    
    func checkForEdit() {
        // Check if user is creating a new client or editing an existing one.
        if let id = editClientId {
            coreDataService.getClientFromID(id)
            isEditingClient = true
        } else { isEditingClient = false }
        // Set the navigation title based on editing state.
        self.title = isEditingClient ? S.editClientTitle.localized : S.addClientTitle.localized
        deleteBarButton.isEnabled = isEditingClient
        deleteBarButton.tintColor = isEditingClient ? .red : .clear
    }
    
    func showAlertDialog() {
        let alertDialog = UIAlertController(title: S.alertTitleMissingInfo.localized,
                                            message: S.alertMessageMissingInfo.localized,
                                            preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            alertDialog.dismiss(animated: true)
        })
        alertDialog.addAction(dismissButton)
        self.present(alertDialog, animated: true, completion: nil)
    }
    
    // If the user selects the delete menu button display alert asking for confirmation.
    func showDeleteAlertDialog() {
        let dialogMessage = UIAlertController(title: S.alertTitleDeleteConfirm.localized,
                                              message: S.alertMessageDeleteConfirm.localized,
                                              preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
            dialogMessage.dismiss(animated: true)
        })
        let confirmButton = UIAlertAction(title: "DELETE!", style: .destructive, handler: { (action) -> Void in
            dialogMessage.dismiss(animated: true)
            // If delete is successful navigate back.
            if self.coreDataService.deleteClient() { self.navigationController?.popViewController(animated: true) }
        })
        
        dialogMessage.addAction(dismissButton)
        dialogMessage.addAction(confirmButton)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func createUpdateClient() {
        // Check if client name is empty or nil. If so show alert dialog.
        guard let company = companyNameTextField.text,
              !company.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlertDialog()
            return
        }
        let contact = contactNameTextField.text
        let phoneNumber = phoneNumberTextField.text
        let email = emailTextField.text
        let address = addressTextField.text
        let rate = payRateTextField.currencyStringToDouble() ?? 0
        let colour = selectedColour
        // Notify service to create or update client using the provided input parameters.
        if coreDataService.createUpdateClient(companyName: company,
                                              contactName: contact,
                                              phone: phoneNumber,
                                              email: email,
                                              address: address,
                                              rate: rate,
                                              tagColour: colour) {
            // If successful navigate back.
            navigationController?.popViewController(animated: true)
        }
    }
    
    func saveClient() -> Bool { return coreDataService.saveToDatabase() }
    
    // Called when save button is pressed
    @IBAction func saveButtonPressed(_ sender: UIButton) { createUpdateClient() }
    // Called when save button is pressed.
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) { showDeleteAlertDialog() }
    
}

// MARK: - AddEditClientManagerDelegate
extension AddEditClientViewController: AddEditClientManagerDelegate {
    func didUpdateCurrencyText(_ addEditClientManager: AddEditClientManager, newCurrencyValue: String?) {
        // Update the text fields input to currency format.
        payRateTextField.text = newCurrencyValue
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        manager.validateCurrencyInput(string: string)
    }
}

// MARK: - CoreDataServiceDelegate
extension AddEditClientViewController: CoreDataServiceDelegate {
    func loadedClient(_ coreDataService: CoreDataService, clientItem: ClientItem?) {
        // If user is updating client, set the text fields corresponding values.
        if let client = clientItem {
            companyNameTextField.text = client.companyName
            contactNameTextField.text = client.contactName
            phoneNumberTextField.text = client.phoneNumber
            emailTextField.text = client.email
            addressTextField.text = client.address
            payRateTextField.text = client.payRate.convertToCurrency()
            if let colour = client.tagColour {
                selectedColour = colour
                tagButton.selectedColour = colour
            }
        }
    }
}

// MARK: - ColourTagButtonDelegate
extension AddEditClientViewController: ColourTagButtonDelegate {
    func didUpdateColourTag(_ colourTagButton: ColourTagButton, hexString: String) {
        selectedColour = hexString
    }
}


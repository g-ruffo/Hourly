//
//  AddEditClientViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-11.
//

import UIKit
import UIColorHexSwift

class AddEditClientViewController: UIViewController {

    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var payRateTextField: UITextField!
    @IBOutlet weak var popUpButton: UIButton!
    
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var selectedColour = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1).hexString()
    
    private var manager = AddEditClientManager()
    

    private let tagStringColours: Array<String> = [
        "#0096FF", "#941751", "#941100", "#FF9300", "#00F900", "#0433FF", "#FF2F92", "#FFFB00", "#942193", "#73FCD6", "#009193", "#FF2600", "#FF85FF", "#FFFC79"
    ]
    
    var clientEdit: ClientItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        print(clientEdit?.id)

        manager.delegate = self
        payRateTextField.delegate = self
        checkForEdit()
        setupPopUpButton()
    }
    
    func checkForEdit() {
        if let client = clientEdit {
            self.title = S.editClientTitle.localized
            companyNameTextField.text = client.companyName
            contactNameTextField.text = client.contactName
            phoneNumberTextField.text = client.phoneNumber
            emailTextField.text = client.email
            addressTextField.text = client.address
            payRateTextField.text = "$\(client.payRate)"
            
            if let colour = client.tagColor {
                selectedColour = colour
            }
        } else {
            deleteBarButton.isEnabled = false
            deleteBarButton.tintColor = .clear
            self.title = S.addClientTitle.localized
        }
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
            self.deleteClientFromDatabase()
            dialogMessage.dismiss(animated: true)
        })
        
        dialogMessage.addAction(dismissButton)
        dialogMessage.addAction(confirmButton)
        // Present alert to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func createClient() {
        let newClient = ClientItem(context: databaseContext)
        newClient.companyName = companyNameTextField.text
        newClient.contactName = contactNameTextField.text
        newClient.phoneNumber = phoneNumberTextField.text
        newClient.email = emailTextField.text
        newClient.address = addressTextField.text
        newClient.payRate = manager.currencyStringToDouble(for: payRateTextField.text) ?? 0
        newClient.tagColor = selectedColour
    }
    
    func updateClient() {
        guard let client = clientEdit else {
            fatalError("Error geting client to perform update.")
        }
        client.companyName = companyNameTextField.text
        client.contactName = contactNameTextField.text
        client.phoneNumber = phoneNumberTextField.text
        client.email = emailTextField.text
        client.address = addressTextField.text
        client.payRate = manager.currencyStringToDouble(for: payRateTextField.text) ?? 0
        client.tagColor = selectedColour
    }
    
    func saveClient() -> Bool {
        if databaseContext.hasChanges {
            do {
                try databaseContext.save()
                return true
            } catch {
                print("Error saving client to database = \(error)")
                return false
            }
        } else {
            return true
        }
    }
    
    func deleteClientFromDatabase() {
        if let client = clientEdit {
            databaseContext.delete(client)
            if saveClient() {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if !companyNameTextField.isValid() || !payRateTextField.isValid() {
            showAlertDialog()
        } else if clientEdit != nil {
            updateClient()
            if saveClient() {
                navigationController?.popViewController(animated: true)
            }
        } else {
            createClient()
            if saveClient() {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        showDeleteAlertDialog()
        
    }
    
}

extension AddEditClientViewController: AddEditClientManagerDelegate {
    func didUpdateCurrencyText(_ addEditClientManager: AddEditClientManager, newCurrencyValue: String?) {
        payRateTextField.text = newCurrencyValue
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        manager.validateCurrencyInput(string: string)
    }
}


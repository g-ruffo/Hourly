//
//  ClientDetailsViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-13.
//

import UIKit

protocol EditClientDelegate: AnyObject {
    func editClient(_ clientDetailsViewController: ClientDetailsViewController, client: ClientItem)
}

class ClientDetailsViewController: UIViewController {
    // MARK: - Variables
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var payRateLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    var client: ClientItem?
    weak var delegate: EditClientDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setClientDetails()
    }
    
    // Set variable values using the provided clients data.
    private func setClientDetails() {
        if let details = client {
            clientNameLabel.text = details.companyName
            payRateLabel.text = "$\(details.payRate)/ hour"
            contactNameTextField.text = details.contactName
            phoneTextField.text = details.phoneNumber
            emailTextField.text = details.email
            addressTextField.text = details.address
            tagImageView.tintColor = UIColor(client?.tagColour ?? "#FFFFFF")
        }
        // Set the state of the action buttons.
        setIntentButtonState()
    }
    
    private func setIntentButtonState() {
        // Set button as disabled if corresponding value is missing.
        guard let phone = phoneTextField.text, let email = emailTextField.text, let address = addressTextField.text else {
            print("TextFields have nil values")
            return
        }
        if phone.isEmpty {
            phoneButton.isEnabled = false
            messageButton.isEnabled = false
        }
        if email.isEmpty { emailButton.isEnabled = false }
        if address.isEmpty { locationButton.isEnabled = false }
    }
    
    // Called when the trailing navigation button is pressed.
    @IBAction func editButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            guard let editClient = self.client else {
                print("Unable to get client to edit")
                self.dismiss(animated: true)
                return
            }
            // Notify parent view controller that the user wants to navigate to the edit screen.
            self.delegate?.editClient(self, client: editClient)
        }
    }
    
    // Called when the phone button is pressed.
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
        if let phone = phoneTextField.text { performIntent(for: "tel:", address: phone) }
    }
    
    // Called when the message button is pressed.
    @IBAction func messageButtonPressed(_ sender: UIButton) {
        if let phone = phoneTextField.text { performIntent(for: "sms:", address: phone) }
    }
    
    // Called when the email button is pressed.
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text { performIntent(for: "mailTo:", address: email) }
    }
    
    // Called when the location button is pressed.
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        if let location = addressTextField.text {
            // Format provided address to a url complient string.
            let formattedAddress = location.replacingOccurrences(of: " ", with: "+")
            performIntent(for: "http://maps.apple.com/?q=", address: formattedAddress)
        }
    }
    
    // MARK: - Intent
    func performIntent(for action: String, address: String) {
        if let url = URL(string: "\(action)\(address)"),
           // Perform intent based on provided input parameters.
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else { print("Unable to perform client intent") }
    }
}

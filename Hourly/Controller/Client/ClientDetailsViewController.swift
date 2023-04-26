//
//  ClientDetailsViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-13.
//

import UIKit

protocol EditClientDelegate {
    func editClient(_ clientDetailsViewController: ClientDetailsViewController, client: ClientItem)
}

class ClientDetailsViewController: UIViewController {
    
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
    
    var delegate: EditClientDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setClientDetails()
    }
    
    private func setClientDetails() {
        if let details = client {
            clientNameLabel.text = details.companyName
            payRateLabel.text = "$\(details.payRate)/ hour"
            contactNameTextField.text = details.contactName
            phoneTextField.text = details.phoneNumber
            emailTextField.text = details.email
            addressTextField.text = details.address
        }
        setIntentButtonState()
    }
    
    private func setIntentButtonState() {
        guard let phone = phoneTextField.text, let email = emailTextField.text, let address = addressTextField.text else {
            fatalError("TextFields have nil values")
        }
        if phone.isEmpty {
            phoneButton.isEnabled = false
            messageButton.isEnabled = false
        }
        if email.isEmpty {
            emailButton.isEnabled = false
        }
        if address.isEmpty {
            locationButton.isEnabled = false
        }
    }

    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            guard let editClient = self.client else {
                fatalError("Unable to get client to edit")
            }
            self.delegate?.editClient(self, client: editClient)
        }
    }
    
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
        if let phone = phoneTextField.text { performIntent(for: "tel:", address: phone) }
    }
    
    @IBAction func messageButtonPressed(_ sender: UIButton) {
        if let phone = phoneTextField.text { performIntent(for: "sms:", address: phone) }
    }
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text { performIntent(for: "mailTo:", address: email) }
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        if let location = addressTextField.text {
            let formattedAddress = location.replacingOccurrences(of: " ", with: "+")
            performIntent(for: "http://maps.apple.com/?q=", address: formattedAddress)
        }
    }
    
    func performIntent(for action: String, address: String) {
        if let url = URL(string: "\(action)\(address)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else { print("Unable to perform client intent") }
    }

}

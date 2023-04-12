//
//  AddEditClientViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-11.
//

import UIKit

class AddEditClientViewController: UIViewController {

    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var payRateTextField: UITextField!
    @IBOutlet weak var tagColourButton: ColorTagButton!
    
    private let tagColours: Array<UIColor> = [
        #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
    ]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tagColourButton.layer.borderColor = UIColor.gray.cgColor
        tagColourButton.layer.borderWidth = 1
        tagColourButton.layer.cornerRadius = 8
        tagColourButton.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1)
        let rightImageColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        tagColourButton.rightHandImage = UIImage(systemName: "chevron.down.circle.fill")?.withTintColor(rightImageColor, renderingMode: .alwaysTemplate)
        tagColourButton.leftHandImage = UIImage(systemName: "circle.fill")?.withTintColor(tagColours[0])
        
    }
    
    @IBAction func colourTabButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
        
    }
}

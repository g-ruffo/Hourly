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
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var tagColourImageView: UIView!
    
    
    @IBOutlet weak var menu: UIMenu!
    
    private let dropDownValues = [
        UIImage(systemName: "circle.fill"),
        UIImage(systemName: "circle.fill"),
        UIImage(systemName: "circle.fill"),
        UIImage(systemName: "circle.fill"),
        UIImage(systemName: "circle.fill"),
        UIImage(systemName: "circle.fill")

    ]
    
    private let tagColours: Array<UIColor> = [
        #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1),
        #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1),
        #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1),
        #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1),
        #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1),
        #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1),
        #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    ]
    private let array = [
    "1", "2", "3", "4", "5", "6", "2", "3", "4", "5", "6", "2", "3", "4", "5", "6"
    ]
    
    @IBOutlet weak var popUpMenu: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    

        let optionClosure = {(action: UIAction) in
                    print(action.title)
                }

        // create an array to store the actions
        var optionsArray = [UIAction]()

        // loop and populate the actions array
        for number in tagColours {
            let image = UIImage(systemName: "circle.fill")?.withTintColor(number, renderingMode: .alwaysOriginal)
            let colored = image?.withTintColor(number)
            // create each action and insert the right country as a title
            let action = UIAction( image: image, state: .off, handler: optionClosure)
                    
            // add newly created action to actions array
            optionsArray.append(action)
        }
                
                
        // set the state of first country in the array as ON
        optionsArray[0].state = .on

        // create an options menu
        let optionsMenu = UIMenu(title: "", options: .displayInline, children: optionsArray)
                
        // add everything to your button
        popUpMenu.menu = optionsMenu

        // make sure the popup button shows the selected value
        popUpMenu.changesSelectionAsPrimaryAction = true
        popUpMenu.showsMenuAsPrimaryAction = true

        
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}


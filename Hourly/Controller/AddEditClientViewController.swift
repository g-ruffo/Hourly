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
    @IBOutlet weak var tagColourPopUpBotton: UIButton!
    
    private let tagColours: Array<UIMenuElement> = [
        
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

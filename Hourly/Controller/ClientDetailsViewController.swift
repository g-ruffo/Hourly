//
//  ClientDetailsViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-13.
//

import UIKit

class ClientDetailsViewController: UIViewController {

    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var payRateLabel: UILabel!
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func messageButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
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

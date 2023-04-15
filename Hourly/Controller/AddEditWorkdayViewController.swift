//
//  WorkdayViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit

class AddEditWorkdayViewController: UIViewController {

    @IBOutlet weak var clientTexfield: UITextField!
    @IBOutlet weak var dateTexfield: UITextField!
    @IBOutlet weak var locationTexfield: UITextField!
    @IBOutlet weak var startTimeTexfield: UITextField!
    @IBOutlet weak var endTimeTexfield: UITextField!
    @IBOutlet weak var lunchTexfield: UITextField!
    @IBOutlet weak var payRateTexfield: UITextField!
    @IBOutlet weak var mileageTexfield: UITextField!
    @IBOutlet weak var descriptionTexfield: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var workday: WorkdayItem?

    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func saveWorkday() -> Bool {
        if databaseContext.hasChanges {
            do {
                try databaseContext.save()
                return true
            } catch {
                print("Error saving workday to database = \(error)")
                return false
            }
        } else {
            return true
        }
    }
    
//    func createWorkday() -> Bool {
//        var workday = WorkDayItem(context: databaseContext)
//        workday.client = clientTexfield.text
//        workday.date = dateTexfield.text
//        workday.location = locationTexfield.text
//        workday.startTime = startTimeTexfield.text
//        workday.endTIme = endTimeTexfield.text
//        workday.lunchBreak = lunchTexfield.text
//        workday.payRate = payRateTexfield.text
//        workday.kmDriven = mileageTexfield.text
//        workday.description = descriptionTexfield.text
//    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
}

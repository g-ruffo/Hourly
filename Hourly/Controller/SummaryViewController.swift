//
//  ViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit
import CoreData

class SummaryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var earningsLabel: UILabel!
    @IBOutlet weak var filterResultsButton: UIButton!
    @IBOutlet weak var billableTImeLabel: UILabel!
    @IBOutlet weak var daysWorkedLabel: UILabel!
    @IBOutlet weak var timesheetsLabel: UILabel!
    @IBOutlet weak var clientsLabel: UILabel!
    
    @IBOutlet weak var workedDaysView: UIView!
    @IBOutlet weak var hoursWorkedView: UIView!
    let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let filterOptions = ["This Week", "This Month", "This Year"]
    
    var workdays: Array<WorkdayItem> = [] {
        didSet {
                let totalEarnings = workdays.compactMap { $0.earnings }.reduce(0, +)
                earningsLabel.text = totalEarnings.convertToCurrency()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WorkdayCell.nib(), forCellReuseIdentifier: K.Cell.workdayCell)
        
        workedDaysView.layer.cornerRadius = 20
        hoursWorkedView.layer.cornerRadius = 20
        
        setupPopUpButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.summaryWorkdayDetailNav {
            let destinationVC = segue.destination as? WorkDetailViewController
            destinationVC?.workday = sender as? WorkdayItem
        }
    }
    
    func loadWorkdaysFromDatabase() {
        let startDate = Date()
        let endDate = Date()
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        do{
            workdays = try databaseContext.fetch(request)
        } catch {
            print("Error fetching workdays from database = \(error)")
        }
    }
    
    func setupPopUpButton() {
        // Called when selection is made
        let optionClosure = {(action: UIAction) in

                }

        var optionsArray = [UIAction]()

        for filter in filterOptions {

            // Create each action and insert the coloured image
            let action = UIAction(title: filter, handler: optionClosure)

            // Add created action to action array
            optionsArray.append(action)
        
        }
                
                
        // set the state of first country in the array as ON
        optionsArray[0].state = .on

        // create an options menu
        let optionsMenu = UIMenu(options: .displayInline, children: optionsArray)
        
                
        // add everything to your button
        filterResultsButton.menu = optionsMenu

        // make sure the popup button shows the selected value
        filterResultsButton.changesSelectionAsPrimaryAction = true
        filterResultsButton.showsMenuAsPrimaryAction = true
    }
}

extension SummaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Segue.summaryWorkdayDetailNav, sender: workdays[indexPath.row])
    }
    
}

extension SummaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.workdayCell, for: indexPath) as! WorkdayCell
        
        cell.configure(with: workdays[indexPath.row])
        
        return cell
    }
    
    
}


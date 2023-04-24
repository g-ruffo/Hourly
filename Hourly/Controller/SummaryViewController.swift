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
    @IBOutlet weak var billableTimeLabel: UILabel!
    @IBOutlet weak var breakTimeLabel: UILabel!
    @IBOutlet weak var totalHoursLabel: UILabel!
    @IBOutlet weak var daysWorkedLabel: UILabel!
    @IBOutlet weak var timesheetsLabel: UILabel!
    @IBOutlet weak var clientsLabel: UILabel!
    @IBOutlet weak var workedDaysView: UIView!
    @IBOutlet weak var hoursWorkedView: UIView!
    
    let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let filterOptions = ["This Week", "This Month", "This Year"]
    
    var manager = SummaryManager()
    
    private let todaysDate = Date()
    
    var workdays: Array<WorkdayItem> = [] {
        didSet {
                let totalEarnings = workdays.compactMap { $0.earnings }.reduce(0, +)
                earningsLabel.text = totalEarnings.convertToCurrency()
            
            let billedHours = workdays.compactMap { Helper.calculateHours(startTime: $0.startTime, endTime: $0.endTime, lunchTime: Int($0.lunchBreak)) }.reduce(0, +)
            billableTimeLabel.text = String(format: "%.2f Hours", billedHours)
            
            let totalBreak = workdays.compactMap { $0.lunchBreak }.reduce(0, +)
            breakTimeLabel.text = manager.minutesToHours(minutes: Int(totalBreak))
            
            let totalHours = workdays.compactMap { Helper.calculateHours(startTime: $0.startTime, endTime: $0.endTime, lunchTime: nil) }.reduce(0, +)
            totalHoursLabel.text = String(format: "%.2f Hours", totalHours)
            
            let calendarWorked = Set(workdays.compactMap { $0.date?.formatDateToString() })
            daysWorkedLabel.text = "\(calendarWorked.count) Days"
            
            let clients = Set(workdays.compactMap { $0.clientName })
            clientsLabel.text = String(clients.count)
            
            timesheetsLabel.text = String(workdays.count)
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

        NotificationCenter.default.addObserver(self, selector: #selector(workdaysHaveBeenUpdated), name: K.NotificationKeys.updateWorkdaysNotification, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPopUpButton()
        loadWorkdaysFromDatabase()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.summaryWorkdayDetailNav {
            let destinationVC = segue.destination as! WorkDetailViewController
            destinationVC.workday = sender as? WorkdayItem
            destinationVC.delegate = self
        } else if segue.identifier == K.Segue.summaryEditWorkdayNav {
            let destinationVC = segue.destination as! AddEditWorkdayViewController
            destinationVC.workdayEdit = sender as? WorkdayItem
        }
    }
    
    @objc func workdaysHaveBeenUpdated(notification: NSNotification) {
        loadWorkdaysFromDatabase()
    }
    
    func loadWorkdaysFromDatabase() {
        var startDate = todaysDate
        var endDate = todaysDate
        switch filterResultsButton.titleLabel?.text {
        case filterOptions[0] : startDate = manager.firstOfWeek(date: todaysDate)
            endDate = manager.lastOfWeek(date: todaysDate)
        case filterOptions[1] : startDate = manager.firstOfMonth(date: todaysDate)
            endDate = manager.lastOfMonth(date: todaysDate)
        case filterOptions[2] : startDate = manager.firstOfYear(date: todaysDate)
            endDate = manager.lastOfYear(date: todaysDate)
        default: print("Error getting start and end dates")
        }
        
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        let sortDate = NSSortDescriptor(key: "date", ascending: false)
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND isFinalized == true", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [sortDate]
        do{
            workdays = try databaseContext.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error fetching workdays from database = \(error)")
        }
    }
    
    func setupPopUpButton() {
        // Called when selection is made
        let optionClosure = {(action: UIAction) in self.loadWorkdaysFromDatabase() }
        
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

//MARK: - UITableViewDelegate
extension SummaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: K.Segue.summaryWorkdayDetailNav, sender: workdays[indexPath.row])
    }
}

//MARK: - UITableViewDataSource
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

//MARK: - EditWorkdayDelegate
extension SummaryViewController: EditWorkdayDelegate {
    func editWorkday(_ workDetailViewController: WorkDetailViewController, workday: WorkdayItem) {
        performSegue(withIdentifier: K.Segue.summaryEditWorkdayNav, sender: workday)
    }
}


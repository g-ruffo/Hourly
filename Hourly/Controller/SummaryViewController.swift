//
//  ViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit
import CoreData

class SummaryViewController: UIViewController {
    // MARK: - Variables
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
    @IBOutlet weak var noDataLabel: UILabel!
    private var coreDataService: CoreDataService
    // Titles for option menu filter selection.
    private let filterOptions = ["This Week", "This Month", "This Year"]
    var manager = SummaryManager()
    private let todaysDate = Date()
    private var workdays: Array<WorkdayItem> = [] {
        didSet {
            // Calculate the total earnings and set the value to label.
            let totalEarnings = workdays.compactMap { $0.earnings }.reduce(0, +)
            earningsLabel.text = totalEarnings.convertToCurrency()
            // Calculate the total billed hours and set the value to label.
            let billedHours = workdays.compactMap { $0.minutesWorked }.reduce(0, +)
            billableTimeLabel.text = manager.minutesToHours(minutes: billedHours)
            // Calculate the total break time and set the value to label.
            let totalBreak = workdays.compactMap { $0.lunchMinutes }.reduce(0, +)
            breakTimeLabel.text = manager.minutesToHours(minutes: totalBreak)
            // Calculate the total worked time and set the value to label.
            let totalTime = billedHours + totalBreak
            totalHoursLabel.text = manager.minutesToHours(minutes: totalTime)
            // Calculate the number of days worked and set the value to label.
            let calendarWorked = Set(workdays.compactMap { $0.date?.formatDateToString() })
            daysWorkedLabel.text = "\(calendarWorked.count) Days"
            // Calculate the number of clients billed and set the value to label.
            let clients = Set(workdays.compactMap { $0.clientName })
            clientsLabel.text = String(clients.count)
            // Calculate the number of entries and set the value to label.
            timesheetsLabel.text = String(workdays.count)
            // Show the no data label if there are no workdays for the selected time frame.
            noDataLabel.isHidden = workdays.count > 0
        }
    }
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.coreDataService = CoreDataService()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegates and datasource.
        coreDataService.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WorkdayCell.nib(), forCellReuseIdentifier: K.Cell.workdayCell)
        workedDaysView.layer.cornerRadius = 20
        hoursWorkedView.layer.cornerRadius = 20
        // Create an observer that is notified when the user adds a new workday.
        NotificationCenter.default.addObserver(self, selector: #selector(workdaysHaveBeenUpdated), name: K.NotificationKeys.updateWorkdaysNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPopUpButton()
        loadWorkdaysFromDatabase()
        // Set the navigation bar title colour to white.
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Navigation.summaryWorkdayDetailNav {
            let destinationVC = segue.destination as? WorkDetailViewController
            destinationVC?.workday = sender as? WorkdayItem
            // Set the destination view controllers delegate as self to listen for navigation requests.
            destinationVC?.delegate = self
        } else if segue.identifier == K.Navigation.summaryEditWorkdayNav {
            let destinationVC = segue.destination as? AddEditWorkdayViewController
            destinationVC?.editWorkdayId = sender as? NSManagedObjectID
        }
    }
    
    @objc func workdaysHaveBeenUpdated(notification: NSNotification) { loadWorkdaysFromDatabase() }
    
    // Load workdays for the time frame selected by the user in the options menu.
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
        // Create fetch request using the date selection as a filter.
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        let sortDate = NSSortDescriptor(key: "date", ascending: false)
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND isFinalized == true", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [sortDate]
        coreDataService.getWorkdays(withRequest: request)
    }
    
    func setupPopUpButton() {
        // Called when selection is made.
        let optionClosure = {(action: UIAction) in self.loadWorkdaysFromDatabase() }
        var optionsArray = [UIAction]()
        for filter in filterOptions {
            // Create each action.
            let action = UIAction(title: filter, handler: optionClosure)
            // Add created action to action array.
            optionsArray.append(action)
        }
        // Set the state of the first item as ON.
        optionsArray[0].state = .on
        // Create an options menu passing in the new options array.
        let optionsMenu = UIMenu(options: .displayInline, children: optionsArray)
        // Add UIMenu to button.
        filterResultsButton.menu = optionsMenu
        // Make sure the menu button shows and displays the selection.
        filterResultsButton.changesSelectionAsPrimaryAction = true
        filterResultsButton.showsMenuAsPrimaryAction = true
    }
}

// MARK: - UITableViewDelegate
extension SummaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: K.Navigation.summaryWorkdayDetailNav, sender: workdays[indexPath.row])
    }
}

// MARK: - UITableViewDataSource
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

// MARK: - EditWorkdayDelegate
extension SummaryViewController: EditWorkdayDelegate {
    func editWorkday(_ workDetailViewController: WorkDetailViewController, workday: WorkdayItem) {
        performSegue(withIdentifier: K.Navigation.summaryEditWorkdayNav, sender: workday.objectID)
    }
}

// MARK: - CoreDataServiceDelegate
extension SummaryViewController: CoreDataServiceDelegate {
    func loadedWorkdays(_ coreDataService: CoreDataService, workdayItems: Array<WorkdayItem>) {
        workdays = workdayItems
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}


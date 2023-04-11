//
//  CalendarViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var listModeMenuItem: UIBarButtonItem!
    
    private var isDisplayingCalendar = true
    
    let calendarView = UICalendarView()
    
    private let workDays: Array<WorkDayItem> = []
    
    private let testDays: Array<TestDay> = [
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay()]

    
    let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect required delegates
        calendarView.delegate = self
        tableView.delegate = self
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        searchBar.delegate = self
        tableView.dataSource = self
        
        // Register custom work day cell with table view
        tableView.register(UINib(nibName: K.Identifiers.workdayNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.workdayCell)
        
        
        createCalendar()
    }
    
    @IBAction func switchDisplayModePressed(_ sender: UIBarButtonItem) {
        isDisplayingCalendar.toggle()
        switchDisplayMode()
    }
    
    private func switchDisplayMode() {
        calendarView.isHidden = !isDisplayingCalendar
        tableView.isHidden = isDisplayingCalendar
        searchBar.isHidden = isDisplayingCalendar
        listModeMenuItem.image = isDisplayingCalendar ? UIImage(systemName: "list.bullet") : UIImage(systemName: "calendar")
    }
    
    
    private func createCalendar() {
        let fromDateComponents = DateComponents(calendar: Calendar(identifier: .gregorian), year: 2020, month: 1, day: 1)
        let toDateComponents = DateComponents(calendar: Calendar(identifier: .gregorian), year: 2024, month: 12, day: 31)

        guard let fromDate = fromDateComponents.date, let toDate = toDateComponents.date else {
            return
        }

        let calendarViewDateRange = DateInterval(start: fromDate, end: toDate)
        
        calendarView.availableDateRange = calendarViewDateRange
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.calendar = .current
        calendarView.locale = .current
        calendarView.fontDesign = .rounded
        calendarView.backgroundColor = .white
        calendarView.layer.cornerRadius = 12
        calendarView.layer.borderColor = UIColor.black.cgColor

        view.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    

}

//MARK: - UICalendarViewDelegate

extension CalendarViewController: UICalendarViewDelegate {
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        
        return nil
    }
}

//MARK: - UICalendarSelectionSingleDateDelegate

extension CalendarViewController: UICalendarSelectionSingleDateDelegate {
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        return true
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {

    }
}

//MARK: - UITableViewDelegate

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}


//MARK: - UITableViewDataSource

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testDays.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.workdayCell, for: indexPath) as! WorkdayCell
        
        let workDay = testDays[indexPath.row]
        cell.clientLabel.text = workDay.client
        cell.dateLabel?.text = workDay.date
        cell.earningsLabel?.text = workDay.earnings
        cell.hoursLabel?.text = workDay.hoursWorked
        cell.backgroundColor = .clear


        return cell
    }
}

//MARK: - UISearchBarDelegate
extension CalendarViewController: UISearchBarDelegate {
    
}





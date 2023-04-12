//
//  WorkListViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-11.
//


import UIKit

class WorkListViewController: UIViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var isDisplayingCalendar = true
        
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
        tableView.delegate = self
        searchBar.delegate = self
        tableView.dataSource = self
        
        // Register custom work day cell with table view
        tableView.register(UINib(nibName: K.Identifiers.workdayNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.workdayCell)
    }

}

//MARK: - UITableViewDelegate

extension WorkListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}


//MARK: - UITableViewDataSource

extension WorkListViewController: UITableViewDataSource {
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
extension WorkListViewController: UISearchBarDelegate {
    
}





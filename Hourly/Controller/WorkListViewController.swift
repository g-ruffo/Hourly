//
//  WorkListViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-11.
//


import UIKit
import CoreData

class WorkListViewController: UIViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var isDisplayingCalendar = true
        
    private var workDayList: Array<WorkdayItem> = []
    private var workdaytToEdit: WorkdayItem?
    
    private let manager = WorkdayListManager()
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect required delegates
        tableView.delegate = self
        searchBar.delegate = self
        tableView.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        workdaytToEdit = nil
        loadWorkdayFromDatabase()
    }
    
    func loadWorkdayFromDatabase() {
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        do{
            workDayList = try databaseContext.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error fetching clients from database = \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.workDetailNav {
            let destinationVC = segue.destination as! WorkDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.workday = workDayList[indexPath.row]
            }
        }
    }
}

//MARK: - UITableViewDelegate

extension WorkListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Segue.workDetailNav, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - UITableViewDataSource

extension WorkListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workDayList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.workdayCell, for: indexPath) as! WorkdayCell
        
        let workDay = workDayList[indexPath.row]
        cell.clientLabel.text = workDay.clientName
        cell.dateLabel?.text = manager.dateToString(date: workDay.date)
        cell.earningsLabel?.text = manager.convertDoubleToEarnings(earnings: workDay.earnings)
        cell.hoursLabel?.text = manager.calculateHours(startTime: workDay.startTime, endTime: workDay.endTIme, lunchTime: Int(workDay.lunchBreak))
        cell.backgroundColor = .clear


        return cell
    }
}

//MARK: - UISearchBarDelegate
extension WorkListViewController: UISearchBarDelegate {
    
}

extension WorkListViewController: EditWorkdayDelegate {
    func editWorkday(_ workDetailViewController: WorkDetailViewController, workday: WorkdayItem) {
        workdaytToEdit = workday
        performSegue(withIdentifier: K.Segue.editWorkdayNav, sender: self)
    }
}





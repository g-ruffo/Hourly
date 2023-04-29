//
//  WorkListViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-11.
//


import UIKit
import CoreData

class WorkdaysViewController: UIViewController {
    // MARK: - Variables
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    private var workdays: Array<WorkdayItem> = []
    private var manager = WorkdaysManager()
    private let coreDataService = CoreDataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set delegates and data source.
        coreDataService.delegate = self
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        // Add observer to get notified when the user adds a new workday.
        NotificationCenter.default.addObserver(self, selector: #selector(workdaysHaveBeenUpdated), name: K.NotificationKeys.updateWorkdaysNotification, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWorkdayFromDatabase()
    }
    @objc func workdaysHaveBeenUpdated(notification: NSNotification) {
        // Reload workdays if the user has made changes.
        loadWorkdayFromDatabase()
    }
    func loadWorkdayFromDatabase(searchWorkdays: String? = nil) {
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        // Sort workdays by descending date.
        let sortDate = NSSortDescriptor(key: "date", ascending: false)
        // If searchWorkdays is not nil create a predicate for the users search request.
        if let search = searchWorkdays {
            // The predicate will return all workdays with matching client names.
            let predicate = NSPredicate(format: "clientName CONTAINS[cd] %@", search)
            request.predicate = predicate
        }
        request.sortDescriptors = [sortDate]
        coreDataService.getWorkdays(withRequest: request)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Navigation.workDetailNav {
            let destinationVC = segue.destination as? WorkDetailViewController
            // Pass the selected workday to the destination view controller.
            destinationVC?.workday = sender as? WorkdayItem
            // Set the destination view controllers delegate to self to listen for navigation requests.
            destinationVC?.delegate = self
        } else if segue.identifier == K.Navigation.editWorkdayNav {
            let destinationVC = segue.destination as? AddEditWorkdayViewController
            // Pass the selected workday id to the destination view controller.
            destinationVC?.editWorkdayId = sender as? NSManagedObjectID
        }
    }
}
// MARK: - UITableViewDelegate
extension WorkdaysViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Navigation.workDetailNav, sender: workdays[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - UITableViewDataSource
extension WorkdaysViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workdays.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.workdayCell, for: indexPath) as! WorkdayCell
        let workDay = workdays[indexPath.row]
        cell.configure(with: workDay)
        return cell
    }
}
// MARK: - UISearchBarDelegate
extension WorkdaysViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text, !searchText.isEmpty {
            loadWorkdayFromDatabase(searchWorkdays: searchText)
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // If the search bar has been cleared dismiss the keyboard.
        if searchText.isEmpty {
            searchBar.resignFirstResponder()
            loadWorkdayFromDatabase()
        }
    }
}
// MARK: - EditWorkdayDelegate
extension WorkdaysViewController: EditWorkdayDelegate {
    func editWorkday(_ workDetailViewController: WorkDetailViewController, workday: WorkdayItem) {
        performSegue(withIdentifier: K.Navigation.editWorkdayNav, sender: workday.objectID)
    }
}
// MARK: - CoreDataServiceDelegate
extension WorkdaysViewController: CoreDataServiceDelegate {
    func loadedWorkdays(_ coreDataService: CoreDataService, workdayItems: Array<WorkdayItem>) {
        workdays = workdayItems
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}






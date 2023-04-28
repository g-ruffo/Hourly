//
//  WorkListViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-11.
//


import UIKit
import CoreData

class WorkdaysViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var workdays: Array<WorkdayItem> = []
    
    private var manager = WorkdaysManager()
    private let coreDataService = CoreDataService()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Connect required delegates
        coreDataService.delegate = self
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
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
        loadWorkdayFromDatabase()
    }
    
    func loadWorkdayFromDatabase(searchWorkdays: String? = nil) {
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        let sortDate = NSSortDescriptor(key: "date", ascending: false)
        if let search = searchWorkdays {
            let predicate = NSPredicate(format: "clientName CONTAINS[cd] %@", search)
            request.predicate = predicate
        }
        request.sortDescriptors = [sortDate]

        coreDataService.getWorkdays(withRequest: request)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.workDetailNav {
            let destinationVC = segue.destination as! WorkDetailViewController
                destinationVC.workday = sender as? WorkdayItem
                destinationVC.delegate = self
            
        } else if segue.identifier == K.Segue.editWorkdayNav {
            let destinationVC = segue.destination as! AddEditWorkdayViewController
            destinationVC.editWorkdayId = sender as? NSManagedObjectID
        }
    }
}

//MARK: - UITableViewDelegate
extension WorkdaysViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Segue.workDetailNav, sender: workdays[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - UITableViewDataSource
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

//MARK: - UISearchBarDelegate
extension WorkdaysViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text, !searchText.isEmpty {
            loadWorkdayFromDatabase(searchWorkdays: searchText)
        }
    }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBar.resignFirstResponder()
            loadWorkdayFromDatabase()
        }
    }
}

//MARK: - EditWorkdayDelegate
extension WorkdaysViewController: EditWorkdayDelegate {
    func editWorkday(_ workDetailViewController: WorkDetailViewController, workday: WorkdayItem) {
        performSegue(withIdentifier: K.Segue.editWorkdayNav, sender: workday.objectID)
    }
}

//MARK: - CoreDataServiceDelegate
extension WorkdaysViewController: CoreDataServiceDelegate {
    func loadedWorkdays(_ coreDataService: CoreDataService, workdayItems: Array<WorkdayItem>) {
        workdays = workdayItems
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}






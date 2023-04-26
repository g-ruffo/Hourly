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
    
    private var isDisplayingCalendar = true
        
    private var workdayList: Array<WorkdayItem> = []
    
    private var manager = WorkdaysManager()
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Connect required delegates
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
    
    func loadWorkdayFromDatabase(searchWorkday: String? = nil) {
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        let sortDate = NSSortDescriptor(key: "date", ascending: false)
        if let search = searchWorkday {
            let predicate = NSPredicate(format: "clientName CONTAINS[cd] %@", search)
            request.predicate = predicate
        }
        request.sortDescriptors = [sortDate]

        do{
            workdayList = try databaseContext.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error fetching clients from database = \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.workDetailNav {
            let destinationVC = segue.destination as! WorkDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.workday = workdayList[indexPath.row]
                destinationVC.delegate = self
            }
        } else if segue.identifier == K.Segue.editWorkdayNav {
            let destinationVC = segue.destination as! AddEditWorkdayViewController
            destinationVC.editWorkdayId = sender as? NSManagedObjectID
        }
    }
}

//MARK: - UITableViewDelegate

extension WorkdaysViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Segue.workDetailNav, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - UITableViewDataSource

extension WorkdaysViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workdayList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.workdayCell, for: indexPath) as! WorkdayCell
        let workDay = workdayList[indexPath.row]
        cell.configure(with: workDay)
        return cell
    }
}

//MARK: - UISearchBarDelegate
extension WorkdaysViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text, !searchText.isEmpty {
            loadWorkdayFromDatabase(searchWorkday: searchText)
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







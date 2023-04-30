//
//  ClientsViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit
import CoreData
import UIColorHexSwift

class ClientsViewController: UIViewController {
    // MARK: - Variables
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    private var clients: Array<ClientItem> = []
    private let coreDataService = CoreDataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set view delegates and datasource.
        coreDataService.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadClientsFromDatabase()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Navigation.detailClientNav {
            let destinationVC = segue.destination as? ClientDetailsViewController
            // Pass the selected client to the destination view controller.
            destinationVC?.client = sender as? ClientItem
            // Set the destination view controllers delegate as self to listen for navigation requests.
            destinationVC?.delegate = self
        } else if segue.identifier == K.Navigation.editClientNav {
            let destinationVC = segue.destination as? AddEditClientViewController
            // Pass the selected client id to the destination view controller.
            destinationVC?.editClientId = sender as? NSManagedObjectID
        }
    }
    func loadClientsFromDatabase(searchClients: String? = nil) {
        let request: NSFetchRequest<ClientItem> = ClientItem.fetchRequest()
        // If searchClients is not nil create predicate for users search inquiry.
        if let search = searchClients {
            let predicate = NSPredicate(format: "companyName CONTAINS[cd] %@", search)
            request.predicate = predicate
        }
        coreDataService.getClients(withRequest: request)
    }    
    // Called when trailing navigation button is pressed.
    @IBAction func createClientPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.Navigation.addClientNav, sender: self)
    }
}
// MARK: - UITableViewDataSource
extension ClientsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let client = clients[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.clientCell, for: indexPath) as! ClientCell
        if let colour = client.tagColour {
            cell.tagImageView.image = UIImage(systemName: "circle.fill")?.withTintColor(UIColor(colour), renderingMode: .alwaysOriginal)
        }
        cell.nameLabel.text = client.companyName
        cell.phoneLabel.text = client.phoneNumber
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ClientsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Navigation.detailClientNav, sender: clients[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - UISearchBarDelegate
extension ClientsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text, !searchText.isEmpty {
            loadClientsFromDatabase(searchClients: searchText)
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Dismiss keyboard when the text field has been cleared.
        if searchText.isEmpty {
            searchBar.resignFirstResponder()
            loadClientsFromDatabase()
        }
    }
}
// MARK: - EditClientDelegate
extension ClientsViewController: EditClientDelegate {    
    func editClient(_ clientDetailsViewController: ClientDetailsViewController, client: ClientItem) {
        performSegue(withIdentifier: K.Navigation.editClientNav, sender: client.objectID)
    }
}
// MARK: - CoreDataServiceDelegate
extension ClientsViewController: CoreDataServiceDelegate {
    func loadedClients(_ coreDataService: CoreDataService, clientItems: Array<ClientItem>) {
        // Show no data label if workday list is empty.
        noDataLabel.isHidden = clientItems.count > 0
        clients = clientItems
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}

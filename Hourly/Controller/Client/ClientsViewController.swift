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

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var clients: Array<ClientItem> = []
    
    private let coreDataService = CoreDataService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup view delegates
        coreDataService.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadClientsFromDatabase()
    }
    
    func loadClientsFromDatabase() {
        let request: NSFetchRequest<ClientItem> = ClientItem.fetchRequest()
        coreDataService.getClients(withRequest: request)
    }    

    @IBAction func createClientPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.Identifiers.addClientNav, sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Identifiers.detailClientNav {
            let destinationVC = segue.destination as! ClientDetailsViewController
                destinationVC.client = sender as? ClientItem
                destinationVC.delegate = self

        } else if segue.identifier == K.Segue.editClientNav {
            let destinationVC = segue.destination as! AddEditClientViewController
            destinationVC.editClientId = sender as? NSManagedObjectID
        }
    }
}

//MARK: - UITableViewDataSource
extension ClientsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let client = clients[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.clientCell, for: indexPath) as! ClientCell

        if let colour = client.tagColor {
            cell.tagImageView.image = UIImage(systemName: "circle.fill")?.withTintColor(UIColor(colour), renderingMode: .alwaysOriginal)
        }
        
        cell.nameLabel.text = client.companyName
        cell.phoneLabel.text = client.phoneNumber
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ClientsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Identifiers.detailClientNav, sender: clients[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UISearchBarDelegate
extension ClientsViewController: UISearchBarDelegate {
    
}

//MARK: - EditClientDelegate
extension ClientsViewController: EditClientDelegate {    
    func editClient(_ clientDetailsViewController: ClientDetailsViewController, client: ClientItem) {
        performSegue(withIdentifier: K.Segue.editClientNav, sender: client.objectID)
    }
}

//MARK: - CoreDataServiceDelegate
extension ClientsViewController: CoreDataServiceDelegate {
    func loadedClients(_ coreDataService: CoreDataService, clientItems: Array<ClientItem>) {
        clients = clientItems
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}

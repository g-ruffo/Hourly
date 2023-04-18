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
    
    private var clientList: Array<ClientItem> = []
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var clientToEdit: ClientItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup view delegates
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clientToEdit = nil
        loadClientsFromDatabase()
    }
    
    func loadClientsFromDatabase() {
        let request: NSFetchRequest<ClientItem> = ClientItem.fetchRequest()
        do{
            clientList = try databaseContext.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error fetching clients from database = \(error)")
        }
    }    

    @IBAction func createClientPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.Identifiers.addClientNav, sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Identifiers.detailClientNav {
            let destinationVC = segue.destination as! ClientDetailsViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.client = clientList[indexPath.row]
                destinationVC.delegate = self
            }
        } else if segue.identifier == K.Identifiers.editClientNav {
            let destinationVC = segue.destination as! AddEditClientViewController
            destinationVC.clientEdit = clientToEdit
        }
    }
}

//MARK: - UITableViewDataSource

extension ClientsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let client = clientList[indexPath.row]
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
        performSegue(withIdentifier: K.Identifiers.detailClientNav, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UISearchBarDelegate

extension ClientsViewController: UISearchBarDelegate {
    
}

//MARK: - EditClientDelegate

extension ClientsViewController: EditClientDelegate {    
    func editClient(_ clientDetailsViewController: ClientDetailsViewController, client: ClientItem) {
        clientToEdit = client
        performSegue(withIdentifier: K.Identifiers.editClientNav, sender: self)
    }
}

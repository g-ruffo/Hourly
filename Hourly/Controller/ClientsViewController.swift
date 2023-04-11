//
//  ClientsViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit

class ClientsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var clientList: Array<ClientItem> = []
    
    let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup view delegates
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        // Register custom work day cell with table view
        tableView.register(UINib(nibName: K.Identifiers.clientNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.clientCell)
    }
    

    @IBAction func createClientPressed(_ sender: UIBarButtonItem) {
    }

}

extension ClientsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.clientCell, for: indexPath)
        
        return cell
    }
}

extension ClientsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

//MARK: - UISearchBarDelegate
extension ClientsViewController: UISearchBarDelegate {
    
}

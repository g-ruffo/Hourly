//
//  SettingsViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit

struct MenuItem {
    let image: UIImage?
    let title: String
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    fileprivate let menuItems: Array<MenuItem> = [
        MenuItem(image: UIImage(systemName: "person.text.rectangle.fill"), title: S.clientsTitle.localized),
        MenuItem(image: UIImage(systemName: "externaldrive.fill"), title: S.exportTitle.localized)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegate and datasource.
        tableView.delegate = self
        tableView.dataSource = self
        // Set the navigation title to large.
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.register(UINib(nibName: K.Identifiers.settingsNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.settingsCell)

    }

}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = menuItems[indexPath.row].title
        // Navigate based on selected table view item.
        switch selection {
        case S.clientsTitle.localized: performSegue(withIdentifier: K.Segue.clientsNav, sender: self)
        case S.exportTitle.localized: performSegue(withIdentifier: K.Identifiers.exportNav, sender: self)
        default : print("No selection found")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.settingsCell, for: indexPath) as! SettingsCell
        let image = menuItems[indexPath.row].image
        let title = menuItems[indexPath.row].title
        cell.titleLabel.text = title
        cell.iconImageView?.image = image
        return cell
    }
}

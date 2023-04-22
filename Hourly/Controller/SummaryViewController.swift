//
//  ViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit

class SummaryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var earningsLabel: UILabel!
    @IBOutlet weak var filterResultsButton: UIButton!
    
    let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var workdays: Array<WorkdayItem> = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WorkdayCell.nib(), forCellReuseIdentifier: K.Cell.workdayCell)

    }
    
}

extension SummaryViewController: UITableViewDelegate {
    
    
}

extension SummaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.workdayCell, for: indexPath) as! WorkdayCell
        
        cell.configure(with: workdays[indexPath.row])
        
        return cell
    }
    
    
}


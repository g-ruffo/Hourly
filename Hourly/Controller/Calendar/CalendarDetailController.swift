//
//  CalendarDetailController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-21.
//

import UIKit

class CalendarDetailController: UITableViewController {
    
    var workdays: Array<WorkdayItem> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CalendarDetailCell.nib(), forCellReuseIdentifier: K.Cell.calendarDetailCell)
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workdays.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.calendarDetailCell, for: indexPath) as! CalendarDetailCell
        cell.configure(with: workdays[indexPath.row])
        return cell
    }
}

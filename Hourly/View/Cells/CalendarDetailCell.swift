//
//  CalendarDetailCell.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-21.
//

import UIKit

class CalendarDetailCell: UITableViewCell {
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var lunchTimeLabel: UILabel!
    @IBOutlet weak var hoursWorkedLabel: UILabel!
    @IBOutlet weak var payRateLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    var workday: WorkdayItem? {
        didSet {
            if let day = workday {
                clientLabel.text = day.clientName
                dateLabel.text = day.date?.formatDateToString()
                startTimeLabel.text = day.startTime?.formatTimeToString()
                endTimeLabel.text = day.endTime?.formatTimeToString()
                lunchTimeLabel.text = "\(day.lunchMinutes) min"
                hoursWorkedLabel.text = Helper.minutesToHoursWorkedString(minutesWorked: day.minutesWorked)
                payRateLabel.text = day.payRate.convertToCurrency()
                mileageLabel.text = "\(day.mileage) km"
                if let clientTag = day.client?.tagColour {
                    headerView.backgroundColor = UIColor(clientTag).withAlphaComponent(0.6)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headerView.backgroundColor?.withAlphaComponent(0.6)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // Helper function to retrieve nib name when registering in view controller.
    static func nib() -> UINib {
        return UINib(nibName: K.Cell.calendarDetailCell, bundle: nil)
    }
    
    public func configure(with day: WorkdayItem) {
        workday = day
    }
}

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
    @IBOutlet weak var headerStackView: UIStackView!
    
    var workday: WorkdayItem? {
        didSet {
            if let day = workday {
                clientLabel.text = day.clientName
                dateLabel.text = day.date?.formatDateToString()
                startTimeLabel.text = day.startTime?.formatTimeToString()
                endTimeLabel.text = day.endTime?.formatTimeToString()
                lunchTimeLabel.text = "\(day.lunchBreak) min"
                hoursWorkedLabel.text = Helper.minutesToHoursWorkedString(minutesWorked: day.minutesWorked)
                payRateLabel.text = day.payRate.convertToCurrency()
                mileageLabel.text = "\(day.mileage) km"
                if let clientTag = day.client?.tagColor {
                    headerStackView.backgroundColor = UIColor(clientTag).withAlphaComponent(0.8)
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headerStackView.backgroundColor?.withAlphaComponent(0.8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: K.Cell.calendarDetailCell, bundle: nil)
    }
    
    public func configure(with day: WorkdayItem) {
        workday = day
    }
}

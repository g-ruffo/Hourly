//
//  WorkdayCell.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-22.
//

import UIKit

class WorkdayCell: UITableViewCell {
    
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var earningsLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var clientTagImageView: UIImageView!
    
    var workday: WorkdayItem? {
        didSet {
            if let day = workday {
                clientLabel.text = day.clientName
                dateLabel?.text = day.date?.formatDateToString()
                earningsLabel?.text = day.earnings.convertToCurrency()
                hoursLabel?.text = Helper.minutesToHoursWorkedString(minutesWorked: day.minutesWorked)
                clientTagImageView.image = day.isFinalized ? UIImage(systemName: "circle.fill") : UIImage(systemName: "pencil.circle")
                
                if let colour = day.client?.tagColor {
                    clientTagImageView.tintColor = UIColor(colour)
                } else {
                    clientTagImageView.tintColor = UIColor("#ECF0F1")
                }
                
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        contentView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: K.Cell.workdayCell, bundle: nil)
    }
    
    public func configure(with day: WorkdayItem) {
        workday = day
    }
    
}

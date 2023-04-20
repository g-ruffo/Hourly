//
//  WorkDayCell.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit

class WorkdayCell: UITableViewCell {
    
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var earningsLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var clientTagImageView: UIImageView!
    @IBOutlet weak var draftButton: UIButton!
    var workday: WorkdayItem? {
        didSet {
            if let day = workday {
                clientLabel.text = day.clientName
                dateLabel?.text = day.date?.formatDateToString()
               earningsLabel?.text = day.earnings.convertToCurrency()
               hoursLabel?.text = Helper.calculateHours(startTime: day.startTime,
                                                        endTime: day.endTime, lunchTime: Int(day.lunchBreak))
               draftButton.isHidden = day.isFinalized
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
        draftButton.layer.cornerRadius = 8
        draftButton.layer.borderWidth = 1
        draftButton.layer.borderColor = UIColor.green.cgColor
        draftButton.backgroundColor = .green.withAlphaComponent(0.65)
        draftButton.tintColor = UIColor.white

        contentView.backgroundColor = .clear

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setWorkday(_ item: WorkdayItem) {
        workday = item
    }
    
}

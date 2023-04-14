//
//  PayRateHoursCell.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-14.
//

import UIKit

class PayRateHoursCell: UITableViewCell {
    @IBOutlet weak var hoursWorkedLabel: UILabel!
    
    @IBOutlet weak var payRateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

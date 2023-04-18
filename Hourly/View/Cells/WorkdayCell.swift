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
    
}

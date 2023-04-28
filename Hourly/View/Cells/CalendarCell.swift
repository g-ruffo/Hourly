//
//  CalendarCell.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-11.
//

import UIKit

class CalendarCell: UICollectionViewCell {

    @IBOutlet weak var dayOfMonthLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set the corner radius to half the labels height.
        dayOfMonthLabel.layer.cornerRadius = dayOfMonthLabel.frame.height / 2
        dayOfMonthLabel.clipsToBounds = true
    }
    
    func configure(title: String, with days: [WorkdayItem]) {
        dayOfMonthLabel.text = title
        // If title is empty, the cell is representing a day in a different month.
        contentView.backgroundColor = title.isEmpty ? .white.withAlphaComponent(0.5) : .white
        if days.count > 0 {
            // For each workday that has the same date as cell add its tag colour to stackview.
            for day in days {
                let image = UIImageView(image: UIImage(systemName: "square.fill"))
                image.tintColor = .clear

                var colour = UIColor()
                // If the workday is not associated with an existing client set its colour to gray.
                if let tagColour = day.client?.tagColour { colour = UIColor(tagColour) }
                else { colour = .gray }
                // If workday is not finalized set the background colour alpha to 20%.
                if day.isFinalized {
                    image.backgroundColor = colour.withAlphaComponent(0.8)
                } else {
                    image.backgroundColor = colour.withAlphaComponent(0.2)
                }
                image.layer.cornerRadius = (image.frame.height / 2) / CGFloat(days.count)
                stackView.addArrangedSubview(image)
                
            }
        } else {
            // If no workdays for the date are found remove existing views.
            stackView.subviews.forEach { $0.removeFromSuperview()}
        }
    }
}


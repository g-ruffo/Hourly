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
        // Initialization code
        dayOfMonthLabel.layer.cornerRadius = dayOfMonthLabel.frame.height / 2
        dayOfMonthLabel.clipsToBounds = true
    }
    
    func configure(title: String, with days: [WorkdayItem]) {
        dayOfMonthLabel.text = title
        contentView.backgroundColor = title.isEmpty ? .white.withAlphaComponent(0.5) : .white
        
        if days.count > 0 {
            for day in days {
                let image = UIImageView(image: UIImage(systemName: "square.fill"))
                image.tintColor = .clear

                var colour = UIColor()
                
                if let tagColour = day.client?.tagColor { colour = UIColor(tagColour) }
                else { colour = .gray }
                
                if day.isFinalized {
                    image.backgroundColor = colour.withAlphaComponent(0.8)
                } else {
                    image.backgroundColor = colour.withAlphaComponent(0.2)
                }
                image.layer.cornerRadius = (image.frame.height / 2) / CGFloat(days.count)
                stackView.addArrangedSubview(image)
                
            }
        } else {
            stackView.subviews.forEach { $0.removeFromSuperview()}
        }
    }
}


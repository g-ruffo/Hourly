//
//  AddPhotoCell.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-20.
//

import UIKit

class AddPhotoCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.layer.cornerRadius = 20
        contentView.backgroundColor = .white
    }
    
    // Helper function to retrieve nib name when registering in view controller.
    static func nib() -> UINib {
        return UINib(nibName: K.Cell.addPhotoCell, bundle: nil)
    }
}

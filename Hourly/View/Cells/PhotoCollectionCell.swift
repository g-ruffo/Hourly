//
//  PhotoCollectionCell.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-20.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        textView.layer.cornerRadius = 10
        textView.addDoneButtonOnKeyboard()
        // Move the text view based on the position of the keyboard.
        textView.bottomAnchor.constraint(equalTo: contentView.keyboardLayoutGuide.topAnchor, constant: -12).isActive = true

    }
    // Set cell style based on whether the user is editing or viewing the data.
    func setEditingState(_ isEditing: Bool) {
        textView.isEditable = isEditing
        textView.isSelectable = isEditing
        textView.backgroundColor = isEditing ? .white.withAlphaComponent(0.9) : .white.withAlphaComponent(0.1)
        textView.textColor = isEditing ? .black : .white
    }
}



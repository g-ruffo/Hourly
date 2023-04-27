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
        textView.bottomAnchor.constraint(equalTo: contentView.keyboardLayoutGuide.topAnchor, constant: -28).isActive = true
    }
    
    func setEditingState(_ isEditing: Bool) {
        textView.isEditable = isEditing
        textView.isSelectable = isEditing
        textView.backgroundColor = isEditing ? .white.withAlphaComponent(0.9) : .white.withAlphaComponent(0.1)
        textView.textColor = isEditing ? .black : .white
    }
}

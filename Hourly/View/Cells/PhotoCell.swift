//
//  PhotoCell.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-19.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func awakeFromNib() {
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
    }
    
    public func configure(with image: UIImage) {
        imageView.image = image
    }
    
    static func nib() -> UINib {
        return UINib(nibName: K.Cell.photoCell, bundle: nil)
    }
}

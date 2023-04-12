//
//  ColorTagButton.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-11.
//

import UIKit

class ColorTagButton: UIButton {
        @IBInspectable var leftHandImage: UIImage? {
            didSet {
                leftHandImage = leftHandImage?.withRenderingMode(.alwaysOriginal)
                setupImages()
            }
        }
        @IBInspectable var rightHandImage: UIImage? {
            didSet {
                rightHandImage = rightHandImage?.withRenderingMode(.alwaysTemplate)
                setupImages()
            }
        }

        func setupImages() {
            if let leftImage = leftHandImage {
                var configuration = UIButton.Configuration.bordered()
                configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: self.frame.width - (self.imageView?.frame.width)!)
                self.configuration = configuration
                self.setImage(leftImage, for: .normal)
                self.imageView?.contentMode = .scaleAspectFill
              
            }

            if let rightImage = rightHandImage {
                let rightImageView = UIImageView(image: rightImage)
                rightImageView.tintColor = .blue
                let height = self.frame.height / 2
                let width = height
                let xPos = self.frame.width
                let yPos = (self.frame.height - height) / 2
                rightImageView.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
                self.addSubview(rightImageView)
            }
        }
    }

//
//  HourlyTabBar.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit

class HourlyTabBar: UITabBar {
    // MARK: - Variables
    public var didTapButton: (() -> ())?
    // Create middle button to disblay in tab bar.
    public lazy var middleButton: UIButton! = {
        let middleButton = UIButton()
        middleButton.frame.size = CGSize(width: K.NavigationBar.middleButtonSize, height: K.NavigationBar.middleButtonSize)
        var configuration = UIButton.Configuration.filled()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        configuration.baseBackgroundColor = #colorLiteral(red: 0.9450980392, green: 0.768627451, blue: 0.05882352941, alpha: 1)
        configuration.baseForegroundColor = #colorLiteral(red: 0.2235294118, green: 0.2431372549, blue: 0.2745098039, alpha: 1)
        configuration.background.cornerRadius = K.NavigationBar.middleButtonRadius
        configuration.cornerStyle = .dynamic
        configuration.image = UIImage(systemName: "plus")
        middleButton.configuration = configuration
        // Add target to notify function when user presses the button.
        middleButton.addTarget(self, action: #selector(self.middleButtonAction), for: .touchUpInside)
        self.addSubview(middleButton)
        return middleButton
    }()
    
    // MARK: - View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.4
        self.layer.masksToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set the middle buttons position to the center and up 5p.
        middleButton.center = CGPoint(x: frame.width / 2, y: 5)
    }
    
    // MARK: - Actions
    @objc func middleButtonAction(sender: UIButton) {
        didTapButton?()
    }
    
    // MARK: - HitTest
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        // Check to see if middle button was pressed.
        return self.middleButton.frame.contains(point) ? self.middleButton : super.hitTest(point, with: event)
    }
}

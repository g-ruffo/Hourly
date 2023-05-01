//
//  ColorTagButton.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-11.
//

import UIKit

protocol ColourTagButtonDelegate: AnyObject {
    func didUpdateColourTag(_ colourTagButton: ColourTagButton, hexString: String)
}

class ColourTagButton: UIButton {
    // MARK: - Variables
    weak var delegate: ColourTagButtonDelegate?
    // Colour choices the user can pick from for a given client tag.
    private let tagStringColours: Array<String> = [
        "#0096FF", "#941751", "#941100", "#FF9300", "#00F900",
        "#0433FF", "#FF2F92", "#FFFB00", "#942193", "#73FCD6",
        "#009193", "#FF2600", "#FF85FF", "#FFFC79"
    ]
    // If the selected colour is nil, the user is creating a new client.
    var selectedColour: String! { didSet { if let _ = selectedColour { configureButton()} } }
    
    func configureButton() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(.gray).withAlphaComponent(0.3).cgColor
        self.layer.cornerRadius = 4
        self.titleLabel?.tintColor = .black
        self.tintColor = UIColor(selectedColour)
        
        // Called when selection is made.
        let optionClosure = {(action: UIAction) in
            self.setImage(action.image, for: .normal)
            self.selectedColour = action.discoverabilityTitle ?? "#0096FF"
            self.delegate?.didUpdateColourTag(self, hexString: self.selectedColour)
        }
        
        var optionsArray = [UIAction]()
        // Create action for each hex colour.
        for hex in tagStringColours {
            let image = UIImage(systemName: "circle.fill")?.withTintColor(UIColor(hex), renderingMode: .alwaysOriginal)
            // Create each action and insert the coloured image.
            let action = UIAction(image: image, discoverabilityTitle: hex, state: .off, handler: optionClosure)
            
            optionsArray.append(action)
        }
        
        // Set the starting menu item. If selected colour is nil, user is creating new client.
        let startingItem = optionsArray.first { $0.discoverabilityTitle == selectedColour } ?? optionsArray[0]
        startingItem.state = .on
        // Create the options menu.
        let optionsMenu = UIMenu(options: .displayInline, children: optionsArray)
        // Set the buttons menu.
        self.menu = optionsMenu
        
        self.showsMenuAsPrimaryAction = true
    }
}


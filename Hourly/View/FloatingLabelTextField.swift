import UIKit

class FloatingLabelTextField: UITextField {
    // MARK: - Variables
    let animationDuration = 0.3
    var floatingLabel = UILabel()
    var floatingLabelFont = UIFont.systemFont(ofSize: 12)
    var backgroundColour = UIColor.white
    var placeholderYPadding: CGFloat = 0.0
    var titleYPadding: CGFloat = 3.0 {
        didSet {
            var frame = floatingLabel.frame
            frame.origin.y = titleYPadding
            floatingLabel.frame = frame
        }
    }
    var floatingLabelNotFocused: UIColor = .gray {
        didSet {
            if !isFirstResponder {
                floatingLabel.textColor = floatingLabelNotFocused
            }
        }
    }
    var floatingLabelInFocus: UIColor! {
        didSet {
            if isFirstResponder {
                floatingLabel.textColor = floatingLabelInFocus
            }
        }
    }
    
    override var placeholder: String? {
        didSet {
            floatingLabel.text = placeholder
            floatingLabel.sizeToFit()
        }
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
        configure()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        configure()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        // Call function when user taps the done button.
        self.addTarget(self, action: #selector(textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
    }
    
    @objc open func textFieldDidEndEditingOnExit() {
        // Hide keyboard when done button is pressed.
        self.resignFirstResponder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setTitlePositionForTextAlignment()
        let isResponder = isFirstResponder
        if let title = text , !title.isEmpty && isResponder {
            floatingLabel.textColor = floatingLabelInFocus
        } else {
            floatingLabel.textColor = floatingLabelNotFocused
        }
        // Set whether to show or hide label.
        if let title = text , title.isEmpty {
            // Hide
            hidePlaceholder(isResponder)
        } else {
            // Show
            showPlaceholder(isResponder)
        }
    }
    
    override func textRect(forBounds bounds:CGRect) -> CGRect {
        var textRect = super.textRect(forBounds: bounds)
        if let txt = text , !txt.isEmpty {
            var top = ceil(floatingLabel.font.lineHeight + placeholderYPadding)
            top = min(top, maxTopInset())
            textRect = textRect.inset(by: UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
        }
        return textRect.integral
    }
    
    override func editingRect(forBounds bounds:CGRect) -> CGRect {
        var editingRect = super.editingRect(forBounds: bounds)
        if let txt = text , !txt.isEmpty {
            var top = ceil(floatingLabel.font.lineHeight + placeholderYPadding)
            top = min(top, maxTopInset())
            editingRect = editingRect.inset(by: UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
        }
        return editingRect.integral
    }
    
    override func clearButtonRect(forBounds bounds:CGRect) -> CGRect {
        var clearButtonRect = super.clearButtonRect(forBounds: bounds)
        if let txt = text , !txt.isEmpty {
            var top = ceil(floatingLabel.font.lineHeight + placeholderYPadding)
            top = min(top, maxTopInset())
            clearButtonRect = CGRect(x:clearButtonRect.origin.x, y:clearButtonRect.origin.y + (top * 0.5), width:clearButtonRect.size.width, height:clearButtonRect.size.height)
        }
        return clearButtonRect.integral
    }
        
    private func configure() {
        self.addDoneButtonOnKeyboard()
        borderStyle = .roundedRect
        floatingLabelInFocus = tintColor
        self.backgroundColor = backgroundColour
        floatingLabel.alpha = 0.0
        floatingLabel.font = floatingLabelFont
        floatingLabel.textColor = floatingLabelNotFocused
        if let string = placeholder , !string.isEmpty {
            floatingLabel.text = string
            floatingLabel.sizeToFit()
            self.attributedPlaceholder = NSAttributedString(
                string: string,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
            )
        }
        self.addSubview(floatingLabel)
    }

    private func maxTopInset() -> CGFloat {
        if let fnt = font {
            return max(0, floor(bounds.size.height - fnt.lineHeight))
        }
        return 0
    }
    
    private func setTitlePositionForTextAlignment() {
        let textRect = textRect(forBounds: bounds)
        var x = textRect.origin.x
        if textAlignment == NSTextAlignment.center {
            x = textRect.origin.x + (textRect.size.width * 0.5) - floatingLabel.frame.size.width
        } else if textAlignment == NSTextAlignment.right {
            x = textRect.origin.x + textRect.size.width - floatingLabel.frame.size.width
        }
        floatingLabel.frame = CGRect(x:x, y:floatingLabel.frame.origin.y, width:floatingLabel.frame.size.width, height:floatingLabel.frame.size.height)
    }
    
    private func showPlaceholder(_ animated:Bool) {
        UIView.animate(withDuration: animationDuration, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseOut], animations:{
            // Set the animation.
                self.floatingLabel.alpha = 1.0
                var frame = self.floatingLabel.frame
                frame.origin.y = self.titleYPadding
                self.floatingLabel.frame = frame
            })
    }
    
    private func hidePlaceholder(_ animated:Bool) {
        UIView.animate(withDuration: animationDuration, delay:0, options: [UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.curveEaseIn], animations:{
            // Set the animation.
            self.floatingLabel.alpha = 0.0
            var frame = self.floatingLabel.frame
            frame.origin.y = self.floatingLabel.font.lineHeight + self.placeholderYPadding
            self.floatingLabel.frame = frame
        })
    }
}

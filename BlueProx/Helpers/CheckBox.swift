//
//  CheckBox.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit

@IBDesignable
open class CheckBox: UIButton {
    
  // MARK: Properties
  
  var borderWidth: CGFloat = 1.75
    
  @IBInspectable
  var uncheckedBorderColor: UIColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
  
  @IBInspectable
  var checkedBorderColor: UIColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
  
  @IBInspectable
  var checkmarkColor: UIColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
  
  var checkboxBackgroundColor: UIColor! = .white
  
  //Used to increase the touchable are for the component
  var increasedTouchRadius: CGFloat = 5
  
  //By default it is true
  var useHapticFeedback: Bool = true
  
  @IBInspectable
  var isChecked: Bool = false {
    didSet{
      self.setNeedsDisplay()
    }
  }
  
  private var feedbackGenerator: UIImpactFeedbackGenerator?
  
  
  // MARK: Init / Deinit
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }
  
  private func setupViews() {
    self.backgroundColor = .clear
  }
  
  open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    self.feedbackGenerator = UIImpactFeedbackGenerator.init(style: .light)
    self.feedbackGenerator?.prepare()
  }
  
  open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.isChecked = !isChecked
    self.sendActions(for: .valueChanged)
    if useHapticFeedback {
      self.feedbackGenerator?.impactOccurred()
      self.feedbackGenerator = nil
    }
  }
  
  open override func draw(_ rect: CGRect) {
    let newRect = rect.insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
    
    let context = UIGraphicsGetCurrentContext()!
    context.setStrokeColor(self.isChecked ? checkedBorderColor.cgColor : tintColor.cgColor)
    context.setFillColor(checkboxBackgroundColor.cgColor)
    context.setLineWidth(borderWidth)
    
    var shapePath: UIBezierPath!
    shapePath = UIBezierPath.init(ovalIn: newRect)
    context.addPath(shapePath.cgPath)
    context.strokePath()
    context.fillPath()

    if isChecked {
      self.drawInnerSquare(frame: newRect)
    }
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    self.setNeedsDisplay()
  }
  
  open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let relativeFrame = self.bounds
    let hitTestEdgeInsets = UIEdgeInsets(top: -increasedTouchRadius, left: -increasedTouchRadius, bottom: -increasedTouchRadius, right: -increasedTouchRadius)
    let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
    return hitFrame.contains(point)
  }
  
  func drawInnerSquare(frame: CGRect) {
    let padding = self.bounds.width * 0.3
    let innerRect = frame.inset(by: .init(top: padding, left: padding, bottom: padding, right: padding))
    let rectanglePath = UIBezierPath.init(roundedRect: innerRect, cornerRadius: 3)
    checkmarkColor.setFill()
    rectanglePath.fill()
  }
  
}

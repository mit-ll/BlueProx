//
//  Extensions.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit


// ------------------------------------------------
// JSON - Encodable extension

struct JSON {
  static let encoder = JSONEncoder()
}
extension Encodable {
  subscript(key: String) -> Any? {
    return dictionary[key]
  }
  var dictionary: [String: Any] {
    return (try? JSONSerialization.jsonObject(with: JSON.encoder.encode(self))) as? [String: Any] ?? [:]
  }
}

// ------------------------------------------------
// UIDevice extension

// Helper to get the type of device
public extension UIDevice {
  static let modelName: String = {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    func mapToDevice(identifier: String) -> String {
      switch identifier {
      case "iPod5,1":                                 return "iPod Touch 5"
      case "iPod7,1":                                 return "iPod Touch 6"
      case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
      case "iPhone4,1":                               return "iPhone 4s"
      case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
      case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
      case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
      case "iPhone7,2":                               return "iPhone 6"
      case "iPhone7,1":                               return "iPhone 6 Plus"
      case "iPhone8,1":                               return "iPhone 6s"
      case "iPhone8,2":                               return "iPhone 6s Plus"
      case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
      case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
      case "iPhone8,4":                               return "iPhone SE"
      case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
      case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
      case "iPhone10,3", "iPhone10,6":                return "iPhone X"
      case "iPhone11,2":                              return "iPhone XS"
      case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
      case "iPhone11,8":                              return "iPhone XR"
      case "iPhone12,1":                              return "iPhone 11"
      case "iPhone12,3":                              return "iPhone 11 Pro"
      case "iPhone12,5":                              return "iPhone 11 Pro Max"
      case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
      case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
      case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
      case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
      case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
      case "iPad6,11", "iPad6,12":                    return "iPad 5"
      case "iPad7,5", "iPad7,6":                      return "iPad 6"
      case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
      case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
      case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
      case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
      case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
      case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
      case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
      case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
      case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
      case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
      default:                                        return identifier
      }
    }
    
    return mapToDevice(identifier: identifier)
  }()
}

// ------------------------------------------------
// URL extension

// Helper to get file size
extension URL {
  var attributes: [FileAttributeKey : Any]? {
    do {
      return try FileManager.default.attributesOfItem(atPath: path)
    } catch let error as NSError {
      print("FileAttribute error: \(error)")
    }
    return nil
  }
  
  var fileSize: UInt64 {
    return attributes?[.size] as? UInt64 ?? UInt64(0)
  }
}

// ------------------------------------------------
// UIButton extensions

extension UIButton {
  func blink(enabled: Bool = true, duration: CFTimeInterval = 0.5, stopAfter: CFTimeInterval = 0.0 ) {
    if enabled {
      (UIView.animate(withDuration: duration, //Time duration you want,
        delay: 0.0,
        options: [.curveEaseInOut, .autoreverse, .repeat],
        animations: { [weak self] in self?.alpha = 0.0 },
        completion: { [weak self] _ in self?.alpha = 1.0 }))
    } else {
      self.layer.removeAllAnimations()
    }
    if !stopAfter.isEqual(to: 0.0) && enabled {
      DispatchQueue.main.asyncAfter(deadline: .now() + stopAfter) {
        [weak self] in
        self?.layer.removeAllAnimations()
      }
    }
  }
  
  func setupRoundedButton(
    controlState: UIControl.State = .normal,
    cornerRadius: CGFloat,
    backgroundColor: UIColor = .lightGray,
    titleColor: UIColor = .white,
    borderWidth: CGFloat = 1,
    borderColor: CGColor = UIColor.black.cgColor,
    tintColor: UIColor = .orange) {
    
    self.backgroundColor = backgroundColor
    
    // NOTE: Overriding inputs
    self.setTitleColor(.white, for: .normal)
    self.setTitleColor(.darkGray, for: .disabled)
    
    self.layer.cornerRadius = cornerRadius
    self.layer.borderWidth = borderWidth
    self.layer.borderColor = borderColor
    self.tintColor = tintColor
  }
  
  func setupRoundedButton() {
    self.setupRoundedButton(cornerRadius: CGFloat(self.frame.height/2))
  }
  
  func setupRoundedButton(backgroundColor: UIColor) {
    self.setupRoundedButton(cornerRadius: CGFloat(self.frame.height/2), backgroundColor: backgroundColor)
  }
  
}

// ------------------------------------------------
// UITextView extensions

extension UITextView {
  func addDoneButton(title: String, target: Any, selector: Selector) {
    
    let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                          y: 0.0,
                                          width: UIScreen.main.bounds.size.width,
                                          height: 44.0))
    let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)
    toolBar.setItems([flexible, barButton], animated: false)//4
    self.inputAccessoryView = toolBar
  }
  
  func setupRoundedTextView() {
    self.layer.cornerRadius = 10
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.black.cgColor
  }
}

// ------------------------------------------------
// UILabel extensions

extension UILabel {
  func setupRoundedLabel() {
    self.sizeToFit()
    self.layer.cornerRadius = 10
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.black.cgColor
  }
}


// ------------------------------------------------
// String extensions

extension String {
  func isValidEmail() -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: self)
  }
}


// ------------------------------------------------
//  UIViewController extensions

extension UIViewController {
  class func storyboardInstance(storyboardId: String, restorationId: String) -> UIViewController {
    let storyboard = UIStoryboard(name: storyboardId, bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: restorationId)
  }
  
  func initMoveViewWithKeyboard() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }

  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      
      let cancelDoneHeight = 40
      var moveOffset = 0
      var textFieldBottomY = 0
      let keyboardTopY = self.view.frame.height - keyboardSize.height
      var availY = 0
      outerLoop: for sv in self.view.subviews {
        if sv.isFirstResponder {
          for ssv in sv.subviews {
            if ssv.isFirstResponder {
              // print("responder found in second level subview: \(sv.description)")
              textFieldBottomY = Int(sv.frame.origin.y + sv.frame.height + CGFloat(cancelDoneHeight))
              availY = Int(keyboardTopY) - textFieldBottomY
              if availY <= 0 {
                moveOffset = -1 * availY
              }
              break outerLoop
            }
          }
          // print("responder found: \(sv.description)")
          textFieldBottomY = Int(sv.frame.origin.y + sv.frame.height + CGFloat(cancelDoneHeight))
          availY = Int(keyboardTopY) - textFieldBottomY
          if availY <= 0 {
            moveOffset = -1 * availY
          }
          break
        }
      }
      
      if self.view.frame.origin.y == 0 {
        self.view.frame.origin.y -= CGFloat(moveOffset) // keyboardSize.height
      }
    }
  }

  @objc func keyboardWillHide(notification: NSNotification) {
      if self.view.frame.origin.y != 0 {
          self.view.frame.origin.y = 0
      }
  }

}

// ------------------------------------------------
// Bundle extensions

extension Bundle {
  
  var releaseVersionNumber: String? {
    return infoDictionary?["CFBundleShortVersionString"] as? String
  }
  
  var buildVersionNumber: String? {
    return infoDictionary?["CFBundleVersion"] as? String
  }
  
  var fullVersionBuildNumber: String? {
    let rvn = Bundle.main.releaseVersionNumber ?? ""
    let bvn = Bundle.main.buildVersionNumber ?? ""
    return rvn + "(" + bvn + ")"
  }
  
}

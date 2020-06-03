//
//  Utility.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit


enum ApplePhone: String, Codable, CaseIterable {
  case none = ""
  case six = "iPhone 6"
  case sixPlus = "iPhone 6 Plus"
  case sixS = "iPhone 6s"
  case sixSPlus = "iPhone 6s Plus"
  case seven = "iPhone 7"
  case sevenPlus = "iPhone 7 Plus"
  case se = "iPhone SE"
  case eight = "iPhone 8"
  case eightPlus = "iPhone 8 Plus"
  case X = "iPhone X"
  case XS = "iPhone XS"
  case XSM = "iPhone XS Max"
  case XR =  "iPhone XR"
  case eleven =  "iPhone 11"
  case elevenPro =  "iPhone 11 Pro"
  case elevenProMax =  "iPhone 11 Pro Max"
  case newer = "iPhone newer"
  case notBlueProxTx = "-- NOT BLUEPROX --"
}

class Utility {
  
  // Sounds
  // http://iphonedevwiki.net/index.php/AudioServices
  static let tweetSoundID: SystemSoundID = 1016
  static let chooChooSoundID: SystemSoundID = 1023
  static let audioToneBusyID: SystemSoundID = 1070
  
  class func tweetAndVibrate() {
    UIDevice.current.isProximityMonitoringEnabled = false
    
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
      print("Playback OK")
      try AVAudioSession.sharedInstance().setActive(true)
      print("Session is Active")
    } catch {
      print(error)
    }
    
    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(tweetSoundID)) { }
    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
    
    UIDevice.current.isProximityMonitoringEnabled = false
    
  }
  
  class func chooChooAndVibrate() {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
      print("Playback OK")
      try AVAudioSession.sharedInstance().setActive(true)
      print("Session is Active")
    } catch {
      print(error)
    }
    
    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(chooChooSoundID)) { }
    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
  }
  
  class func audioToneAndVibrate() {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
      print("Playback OK")
      try AVAudioSession.sharedInstance().setActive(true)
      print("Session is Active")
    } catch {
      print(error)
    }
    
    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(audioToneBusyID)) { }
    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
  }
  
  class func getTimestamp() -> String {
    let date = Date()
    let formatter1 = DateFormatter()
    formatter1.dateFormat = "yyyy-MM-dd"
    let formatter2 = DateFormatter()
    formatter2.dateFormat = "HH:mm:ss.SSS"
    let datePortion = formatter1.string(from: date)
    let timePortion = formatter2.string(from: date)
    return datePortion + "T" + timePortion + "Z"
  }
  
  class func getSessionID() -> String {
    return UUID().description
  }
  
  class func getFileContents(path: String) -> String {
    var contents = ""
    do {
      let fileContent = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
      contents = fileContent as String
      print("fileContent: \(fileContent)")
    } catch {
      print("File not found")
    }
    return contents
  }
  
  class func getFileData(path: String) -> NSData? {
    // Get fileData to be used as attachement
    var data: NSData? = nil
    if let fileData = NSData(contentsOfFile: path) {
      data = fileData
    }
    return data
  }
  
}

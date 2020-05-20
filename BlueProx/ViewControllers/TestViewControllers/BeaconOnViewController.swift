//
//  BeaconOnViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit

class BeaconOnViewController: UIViewController {
  
  // MARK: Properties
  
  // Signal objects
  // Objects from the AppDelegate
  var engSettings: RoleSettings!
  var advertiser: BluetoothAdvertiser!
  var scanner: BluetoothScanner!
  var sensors: Sensors!
  
  var isRunning: Bool = false
  
  
  @IBOutlet weak var blinkingButton: UIButton!
  
  
  // MARK: UIViewController methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initUI()
    
    // Get objects from the AppDelegate
    let delegate = UIApplication.shared.delegate as! AppDelegate
    engSettings = delegate.engSettings
    advertiser = delegate.advertiser
    scanner = delegate.scanner
    sensors = delegate.sensors
    
    // Notifications for when app transitions between background and foreground
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    notificationCenter.addObserver(
      self,
      selector: #selector(proximityChanged),
      name: UIDevice.proximityStateDidChangeNotification,
      object: nil)
    
    // Initialize
    isRunning = false
    
    // Begin
    startRun()
  }
  
  @objc func proximityChanged() {
    print("[STVC | proximityChanged] UIDevice.current.isProximityMonitoringEnabled: " + UIDevice.current.isProximityMonitoringEnabled.description)

    // NOTE: isProximityMonitoringEnabled state being changed
    // under the hood. Therefore set it back to false to prevent
    // proximity sensing which significantly reduces response
    // time of other sensors. However, this
    UIDevice.current.isProximityMonitoringEnabled = false
  }
  
  // Stop any run when we leave the tab
  override func viewWillDisappear(_ animated: Bool) {
    if isRunning {
      stopRun()
    }
  }
  
    
  // MARK: Methods
  
  func initUI() {
    blinkingButton.setupRoundedButton(
      controlState: UIControl.State.normal,
      cornerRadius: CGFloat(blinkingButton.frame.height/2),
      backgroundColor: UIColor.lightGray,
      titleColor: UIColor.white,
      borderWidth: 20,
      borderColor: UIColor.orange.cgColor,
      tintColor: UIColor.red)
    
    // blinkingButton.
    blinkingButton.blink(enabled: true)
  }
  
  // Starts running
  func startRun() {
    advertiser.start()
    scanner.logToFile = false
    scanner.startDetector()
    scanner.startScanForAll()
    sensors.start(settings: engSettings.beacon)
    isRunning = true
    UIDevice.current.isProximityMonitoringEnabled = false
  }
  
  // Stops running
  func stopRun() {
    advertiser.stop()
    scanner.stopDetector()
    scanner.stop()
    sensors.stop()
    isRunning = false
    UIDevice.current.isProximityMonitoringEnabled = false
  }
  
  // When application moves to the background we need
  // to make some adjustments to the Bluetooth operation
  // so it stays alive.
  @objc func didEnterBackground() {
    blinkingButton.blink(enabled: false)
    // Keep proximity off
    UIDevice.current.isProximityMonitoringEnabled = false
    if isRunning {
      // Cycle the advertister
      advertiser.stop()
      advertiser.start()
      
      // Scanner can only scan for one service,
      // and must do so in a timed loop
      scanner.stop()
      scanner.startScanForServiceLoop()
      
      // reset sensors
      sensors.stop()
      sensors.start(settings: engSettings.beacon)
      
      UIDevice.current.isProximityMonitoringEnabled = false
    }
  }
  
  // When application moves to the foreground, we can
  // estore the original Bluetooth operation
  @objc func willEnterForeground() {
    blinkingButton.blink(enabled: true)
    // Keep proximity off
    UIDevice.current.isProximityMonitoringEnabled = false
    if isRunning {
      advertiser.stop()
      advertiser.start()
      
      // Switch scanner from one service to everything
      scanner.stopScanForServiceLoop()
      scanner.startScanForAll()
      
      // reset sensors
      sensors.stop()
      sensors.start(settings: engSettings.beacon)
    }
  }
  
}

//
//  ActivateSensors.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit


protocol RunCompleteDelegate: class {
  func didRunToCompletion()
  func didNotFindBeacon()
}

protocol RSSIDelegate: class {
  func updateRSSIValues(proxRSSI: Int, otherRSSI: Int)
}

class ActivateSensors {
  
  // MARK: Properties
  
  // Sensor related: Objects from the AppDelegate
  var role: String? = nil
  var currentSettings: EngineeringSettings!
  
  var logger: Logger!
  var sensors: Sensors!
  var advertiser: BluetoothAdvertiser!
  var scanner: BluetoothScanner!
  
  // State variables
  var haveInitialLog: Bool = false
  var range: Int? = nil
  var angle: Int? = nil
  var isRunning = false
  var rssiTimer: Timer?
  
  // User notification
  var nextTimer: Timer?
  var nextTimerDurationSeconds: Int = 0
  
  // If we don't see our beacon, BlueProxTx, within
  // checkBeaconMaxTime, then test should abort.
  var checkBeaconTimer: Timer?
  var checkBeaconMaxTime: Int = 3
  
  
  weak var runCompleteDelegate: RunCompleteDelegate?
  weak var rssiDelegate: RSSIDelegate?
  
  // MARK: Initializer
  init(role: String?, nextTimerDurationSeconds: Int, sensorsEnabledSettings: EngineeringSettings? = nil) {
    self.role = role
    self.nextTimerDurationSeconds = nextTimerDurationSeconds
    
    // Get objects from the AppDelegate
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // If sensorsEnabledSettings are specified, use those,
    // otherwise, use the ones from the engineering settings scene
    if let sensorsSettings = sensorsEnabledSettings {
      currentSettings = sensorsSettings
    } else {
      let engSettings = delegate.engSettings
      if role == "Beacon" {
        currentSettings = engSettings?.beacon
      } else if role == "Receiver" {
        currentSettings = engSettings?.receiver
      }
    }
    
    logger = delegate.logger
    sensors = delegate.sensors
    advertiser = delegate.advertiser
    scanner = delegate.scanner
    
    // Notifications for when app transitions between background and foreground
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    
    // Initial states
    haveInitialLog = false
    isRunning = false
  }
  
  // MARK: Methods
  
  func startRun(range: Int, angle: Int, metaData: MetaData, scenarioData: ScenarioModel, beaconSubjectInfo: ScenarioModel) {
    
    // Flush old log and start new one for each run
    createNewLog()
    
    // Write range and angle to the log file
    logger.write("\(scenarioData.loggerDescription)")
    logger.write("\(metaData.loggerDescription)")
    logger.write("\(beaconSubjectInfo.loggerBeaconSubjectDescription)")
    logger.write("Range,\(String(describing: range))")
    logger.write("Angle,\(String(describing: angle))")
    
    // Start any processes
    sensors.start(settings: currentSettings)
    advertiser.start()
    scanner.logToFile = true
    scanner.startScanForAll()
    scanner.resetRSSICounts()
    
    startUpdatingRSSICounts()
    
    // Update state
    isRunning = true
    
    createNextTimer()
    createCheckBeaconTimer()
  }
  
  // RSSI Related
  func startUpdatingRSSICounts() {
    rssiTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRSSICounts), userInfo: nil, repeats: true)
  }
  @objc func updateRSSICounts() {
    rssiDelegate?.updateRSSIValues(
      proxRSSI: scanner.proxRSSICount,
      otherRSSI: scanner.otherRSSICount)
  }
  
  func stopUpdatingRSSICounts() {
    rssiTimer?.invalidate()
    rssiTimer = nil
  }
  
  func wasBlueProxTxFound() -> Bool {
    return scanner.blueProxTxUUIDFound
  }
  
  // When application moves to the background we need to make
  // some adjustments to the Bluetooth operation so it stays alive.
  @objc func didEnterBackground() {
    if isRunning {
      // Cycle the advertister
      advertiser.stop()
      advertiser.start()
      
      // Scanner can only scan for one service, and must do so
      // in a timed loop
      scanner.stop()
      scanner.startScanForServiceLoop()
    }
  }
  
  // When application moves to the foreground, we can restore
  // the original Bluetooth operation
  @objc func willEnterForeground() {
    if isRunning {
      // Cycle the advertister
      advertiser.stop()
      advertiser.start()
      
      // Switch scanner from one service to everything
      scanner.stopScanForServiceLoop()
      scanner.startScanForAll()
    }
  }
  
  func deleteLogs() {
    print("[ActivateSensors | deleteLogs] thread: \(Thread.current)")
    
    if haveInitialLog {
      logger.deleteLogs()
      haveInitialLog = false
    }
  }
  
  func createNewLog() {
    if haveInitialLog {
      print("[ActivateSensors | createNewLog] thread: \(Thread.current)")
    } else {
      logger.createNewLog()
      haveInitialLog = true
    }
  }
  
  // Stops running
  func stopRun() {
    // Stop notification timer
    cancelNextTimer()
    cancelCheckBeaconTimer()
    
    // Stop any processes
    sensors.stop()
    advertiser.stop()
    scanner.logToFile = false
    scanner.stop()
    
    stopUpdatingRSSICounts()
    
    // Update state
    isRunning = false
    
  }
  
  // User notification
  func createNextTimer() {
    if nextTimer == nil {
      let nextTimer = Timer.scheduledTimer(
        timeInterval: TimeInterval(nextTimerDurationSeconds),
        target: self,
        selector: #selector(playSoundAndPause),
        userInfo: nil,
        repeats: true)
      RunLoop.current.add(nextTimer, forMode: .common)
      nextTimer.tolerance = 1.0
      self.nextTimer = nextTimer
    }
  }
  
  @objc private func playSoundAndPause() {
    runCompleteDelegate?.didRunToCompletion()
    stopRun()
    UIDevice.current.isProximityMonitoringEnabled = false
  }
  
  func cancelNextTimer() {
    nextTimer?.invalidate()
    nextTimer = nil
  }
  
  // User notification
  func createCheckBeaconTimer() {
    if checkBeaconTimer == nil {
      let checkBeaconTimer = Timer.scheduledTimer(
        timeInterval: TimeInterval(checkBeaconMaxTime),
        target: self,
        selector: #selector(checkBeaconFoundState),
        userInfo: nil,
        repeats: false)
      RunLoop.current.add(checkBeaconTimer, forMode: .common)
      checkBeaconTimer.tolerance = 1.0
      self.checkBeaconTimer = checkBeaconTimer
    }
  }
  
  @objc private func checkBeaconFoundState() {
    print("[ActivateSensors] checkBeaconFoundState fired ....")
    if scanner.blueProxTxUUIDFound == false {
      // Notify calling test
      runCompleteDelegate?.didNotFindBeacon()
      stopRun()
    }
  }
  
  func cancelCheckBeaconTimer() {
    checkBeaconTimer?.invalidate()
    checkBeaconTimer = nil
  }
  
}

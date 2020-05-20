//
//  LiveMonitorViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit

class LiveDetectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var liveDetectorDataTableView: UITableView!
  
  
  // MARK: Properties
  
  // Workflow related
  var detectorData : [LiveViewData] = []
  
  // Signal objects
  // Objects from the AppDelegate
  var advertiser: BluetoothAdvertiser!
  var scanner: BluetoothScanner!
  var sensors: Sensors!
  
  var isRunning: Bool = false
  var displayTimer: Timer?
  
  // UI related
  @IBOutlet weak var startStopButton: UIButton!
  
  
  // MARK: Initializers
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  // MARK: Conform to UIViewController
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    startStopButton.setupRoundedButton()
    
    liveDetectorDataTableView.delegate = self
    liveDetectorDataTableView.dataSource = self
    
    // Get objects from the AppDelegate
    let delegate = UIApplication.shared.delegate as! AppDelegate
    advertiser = delegate.advertiser
    scanner = delegate.scanner
    sensors = delegate.sensors
    
    // Notifications for when app transitions between background and foreground
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    
    // Initialize
    isRunning = false
  }
  
  // Stop any run when we leave the tab
  override func viewWillDisappear(_ animated: Bool) {
    if isRunning {
      stopRun()
    }
  }
  
  // When application moves to the background we need to make some adjustments to
  // the Bluetooth operation so it stays alive.
  @objc func didEnterBackground() {
    print("11 [LDVC | didEnterBackground]")
    if isRunning {
      print("22 [LDVC | didEnterBackground]")
      // Cycle the advertister
      advertiser.stop()
      advertiser.start()
      
      // Scanner can only scan for one service, and must do so in a timed loop
      scanner.stop()
      scanner.startScanForServiceLoop()
    }
  }
  
  // When application moves to the foreground, we can restore the original Bluetooth
  // operation
  @objc func willEnterForeground() {
    let settings = EngineeringSettings(enabledGroup: SensorsEnabledGroup.bluetoothOnly)
    print("[LDVC | willEnterForeground]")
    if isRunning {
      // Cycle the advertister
      advertiser.stop()
      advertiser.start()
      
      // Switch scanner from one service to everything
      scanner.stopScanForServiceLoop()
      scanner.startScanForAll()
    }
  }
  
  // MARK: Conform to tableview delegate
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Number of rows visible
    return detectorData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProximityDataItem", for: indexPath) as! ProximityDataItemTableViewCell
    let item = detectorData[indexPath.row]
    cell.uuidLabel?.text = item.uuid
    cell.nameLabel?.text = item.name
    cell.rssiLabel?.text = item.rssi.description
    cell.proximityLabel?.text = item.proximity
    
    return cell
  }
  
  
  // MARK: Methods
  // Starts running
  func startRun() {
    advertiser.start()
    scanner.logToFile = false
    scanner.startDetector()
    scanner.startScanForAll()
    
    let settings = EngineeringSettings(enabledGroup: SensorsEnabledGroup.bluetoothOnly)
    
    // clear data
    detectorData.removeAll()
    liveDetectorDataTableView.reloadData()
    
    startUpdatingTable()
    startStopButton.setTitle("Stop", for: .normal)
    isRunning = true
  }
  
  // Stops running
  func stopRun() {
    advertiser.stop()
    scanner.stopDetector()
    scanner.stop()
    
    displayTimer?.invalidate()
    displayTimer = nil
    
    startStopButton.setTitle("Run", for: .normal)
    isRunning = false
  }
  
  func startUpdatingTable() {
    displayTimer = Timer.scheduledTimer(
      timeInterval: 1.0,
      target: self,
      selector: #selector(updateTable), 
      userInfo: nil,
      repeats: true)
  }
  
  @objc func updateTable() {
    print("[updateTable] scanner.detectorData[0].description" + scanner.detectorData.description)
    detectorData = scanner.detectorData
    detectorData = detectorData.sorted(by: {$0.uuid < $1.uuid})
    liveDetectorDataTableView.reloadData()
    scanner.clearDetectorData()
  }
  
  
  // MARK: Actions
  
  @IBAction func startStopButton_TouchUpInside(_ sender: UIButton) {
    if isRunning {
      stopRun()
    } else {
      startRun()
    }
  }
  
}

//
//  LiveMonitorViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit

class LiveDetectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var liveDetectorDataTableView: UITableView!
  @IBOutlet weak var rssiLimitLabel: UILabel!
  @IBOutlet weak var rssiLimitStepper: UIStepper!
  
  
  // MARK: Properties
  
  // Workflow related
  var filtered = false
  var detectorDataDict : [String : LiveViewData] = [:]
  var detectorDataFromDict : Array<(String, LiveViewData)> = []
  var detectorDataFromDictFiltered : Array<(String, LiveViewData)> = []
  
  // Signal objects
  // Objects from the AppDelegate
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
    
    liveDetectorDataTableView.rowHeight = UITableView.automaticDimension
    liveDetectorDataTableView.estimatedRowHeight = 400
    liveDetectorDataTableView.delegate = self
    liveDetectorDataTableView.dataSource = self
    
    // Get objects from the AppDelegate
    let delegate = UIApplication.shared.delegate as! AppDelegate
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
    if isRunning {
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
      // Switch scanner from one service to everything
      scanner.stopScanForServiceLoop()
      scanner.startScanForAll()
    }
  }
  
  // MARK: Conform to tableview delegate
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Number of rows visible
    detectorDataFromDict = detectorDataDict.sorted(by: { $0.0 < $1.0 })
    var numBT = detectorDataFromDictFiltered.count
    filtered = true
    let rssiLimit = Int(rssiLimitLabel.text ?? "0") ?? 0
    if filtered == true {
      detectorDataFromDictFiltered = detectorDataFromDict.filter{$0.1.rssi > rssiLimit}
      numBT = detectorDataFromDictFiltered.count
    }
    return numBT
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProximityDataItem", for: indexPath) as! ProximityDataItemTableViewCell
    
    var item : (String, LiveViewData)
    if filtered {
      item = detectorDataFromDictFiltered[indexPath.row]
    } else {
      item = detectorDataFromDict[indexPath.row]
    }
    
    cell.uuidLabel?.text = item.1.uuid
    cell.nameLabel?.text = item.1.name
    cell.rssiLabel?.text = item.1.rssi.description
    cell.proximityLabel?.text = item.1.proximity
    cell.advTimeLabel?.text = item.1.advTime.description

    return cell
  }
  
  
  // MARK: Methods
  // Starts running
  func startRun() {
    scanner.logToFile = false
    scanner.startDetector()
    scanner.startScanForAll()
    
    let settings = EngineeringSettings(enabledGroup: SensorsEnabledGroup.bluetoothOnly)
    
    detectorDataDict.removeAll()
    liveDetectorDataTableView.reloadData()
    
    startUpdatingTable()
    startStopButton.setTitle("Stop", for: .normal)
    isRunning = true
  }
  
  // Stops running
  func stopRun() {
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
    print("------ [updateTable] scanner.detectorDataDict.description" + scanner.detectorDataDict.description)

    self.detectorDataDict = scanner.detectorDataDict
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
  
  @IBAction func rssiLimitStepper_ValueChanged(_ sender: UIStepper) {
    rssiLimitLabel.text = Int(sender.value).description
  }
  
  
}

//
//  LiveMonitorViewController.swift
//  BluetoothProximity
//
//  Created by Michael Wentz on 4/11/20.
//  Copyright © 2020 Michael Wentz. All rights reserved.
//

import UIKit

class LiveDetectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  
  @IBOutlet weak var liveMonitorDataTableView: UITableView!
  
  
  // MARK: Properties
  
  // Workflow related
  
  // Display data container
  // slz: ... instead, use directly from scanner object....
  // TODO
  var detectorData : [LiveViewData] = []
  
  // Signal objects
  // Objects from the AppDelegate
  var advertiser: BluetoothAdvertiser!
  var scanner: BluetoothScanner!
  
  var isRunning: Bool = false
  var displayTimer: Timer?
  
  
  // UI related
  @IBOutlet weak var startStopButton: UIButton!
  
  
  
  // MARK: Initializers
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  // MARK: Conform to UIViewController
  // Make top navigation bar black with white text
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    startStopButton.setupRoundedButton()
    
    liveMonitorDataTableView.delegate = self
    liveMonitorDataTableView.dataSource = self
    
    // Get objects from the AppDelegate
    let delegate = UIApplication.shared.delegate as! AppDelegate
    advertiser = delegate.advertiser
    scanner = delegate.scanner
    
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
    
    // clear data
    detectorData.removeAll()
    liveMonitorDataTableView.reloadData()
    
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
    print("[updateTable] uuid:" + scanner.detectorData.description)
    detectorData = scanner.detectorData
    liveMonitorDataTableView.reloadData()
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

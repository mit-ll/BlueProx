//
//  EngineeringSettingsViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit


class EngineeringSettingsViewController: UIViewController, UINavigationControllerDelegate {
  
  
  // MARK: Properties
  
  var engSettings: RoleSettings!

  
  // MARK: UI Properties
  
  @IBOutlet weak var beaconProxCheckBox: CheckBox!
  @IBOutlet weak var beaconAccelCheckBox: CheckBox!
  @IBOutlet weak var beaconGyroCheckBox: CheckBox!
  @IBOutlet weak var beaconAttitudeCheckBox: CheckBox!
  @IBOutlet weak var beaconActivityCheckBox: CheckBox!
  @IBOutlet weak var beaconHeadingCheckBox: CheckBox!
  @IBOutlet weak var beaconPedometerCheckBox: CheckBox!
  @IBOutlet weak var beaconAltimeterCheckBox: CheckBox!
  @IBOutlet weak var beaconBluetoothTxCheckBox: CheckBox!
  @IBOutlet weak var beaconBluetoothRxCheckBox: CheckBox!
  
  @IBOutlet weak var receiverProxCheckBox: CheckBox!
  @IBOutlet weak var receiverAccelCheckBox: CheckBox!
  @IBOutlet weak var receiverGyroCheckBox: CheckBox!
  @IBOutlet weak var receiverAttitudeCheckBox: CheckBox!
  @IBOutlet weak var receiverActivityCheckBox: CheckBox!
  @IBOutlet weak var receiverHeadingCheckBox: CheckBox!
  @IBOutlet weak var receiverPedometerCheckBox: CheckBox!
  @IBOutlet weak var receiverAltimeterCheckBox: CheckBox!
  @IBOutlet weak var receiverBluetoothTxCheckBox: CheckBox!
  @IBOutlet weak var receiverBluetoothRxCheckBox: CheckBox!

  
  // MARK: UIViewController Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    engSettings = delegate.engSettings
    navigationController?.delegate = self
    initUI()
  }
  
  
  // MARK: Methods
  
  func initUI() {
    // Init values
    beaconProxCheckBox.isChecked = engSettings.beacon.sensorsEnabledDict[SensorType.proximity]!
    beaconAccelCheckBox.isChecked = engSettings.beacon.sensorsEnabledDict[SensorType.accelerometer]!
    beaconGyroCheckBox.isChecked = engSettings.beacon.sensorsEnabledDict[SensorType.gyroscope]!
    beaconAttitudeCheckBox.isChecked = engSettings.beacon.sensorsEnabledDict[SensorType.attitude]!
    beaconActivityCheckBox.isChecked = engSettings.beacon.sensorsEnabledDict[SensorType.activity]!
    beaconHeadingCheckBox.isChecked = engSettings.beacon.sensorsEnabledDict[SensorType.heading]!
    beaconPedometerCheckBox.isChecked = engSettings.beacon.sensorsEnabledDict[SensorType.pedometer]!
    beaconAltimeterCheckBox.isChecked = engSettings.beacon.sensorsEnabledDict[SensorType.altimeter]!
    beaconBluetoothTxCheckBox.isChecked = engSettings.beacon.sensorsEnabledDict[SensorType.bluetoothTx]!
    beaconBluetoothRxCheckBox.isChecked = engSettings.beacon.sensorsEnabledDict[SensorType.bluetoothRx]!
    
    receiverProxCheckBox.isChecked = engSettings.receiver.sensorsEnabledDict[SensorType.proximity]!
    receiverAccelCheckBox.isChecked = engSettings.receiver.sensorsEnabledDict[SensorType.accelerometer]!
    receiverGyroCheckBox.isChecked = engSettings.receiver.sensorsEnabledDict[SensorType.gyroscope]!
    receiverAttitudeCheckBox.isChecked = engSettings.receiver.sensorsEnabledDict[SensorType.attitude]!
    receiverActivityCheckBox.isChecked = engSettings.receiver.sensorsEnabledDict[SensorType.activity]!
    receiverHeadingCheckBox.isChecked = engSettings.receiver.sensorsEnabledDict[SensorType.heading]!
    receiverPedometerCheckBox.isChecked = engSettings.receiver.sensorsEnabledDict[SensorType.pedometer]!
    receiverAltimeterCheckBox.isChecked = engSettings.receiver.sensorsEnabledDict[SensorType.altimeter]!
    receiverBluetoothTxCheckBox.isChecked = engSettings.receiver.sensorsEnabledDict[SensorType.bluetoothTx]!
    receiverBluetoothRxCheckBox.isChecked = engSettings.receiver.sensorsEnabledDict[SensorType.bluetoothRx]!
    
    // Init checkboxes
    setupCheckbox(checkbox: beaconProxCheckBox)
    setupCheckbox(checkbox: beaconAccelCheckBox)
    setupCheckbox(checkbox: beaconGyroCheckBox)
    setupCheckbox(checkbox: beaconAttitudeCheckBox)
    setupCheckbox(checkbox: beaconActivityCheckBox)
    setupCheckbox(checkbox: beaconHeadingCheckBox)
    setupCheckbox(checkbox: beaconPedometerCheckBox)
    setupCheckbox(checkbox: beaconAltimeterCheckBox)
    setupCheckbox(checkbox: beaconBluetoothTxCheckBox)
    setupCheckbox(checkbox: beaconBluetoothRxCheckBox)

    setupCheckbox(checkbox: receiverProxCheckBox)
    setupCheckbox(checkbox: receiverAccelCheckBox)
    setupCheckbox(checkbox: receiverGyroCheckBox)
    setupCheckbox(checkbox: receiverAttitudeCheckBox)
    setupCheckbox(checkbox: receiverActivityCheckBox)
    setupCheckbox(checkbox: receiverHeadingCheckBox)
    setupCheckbox(checkbox: receiverPedometerCheckBox)
    setupCheckbox(checkbox: receiverAltimeterCheckBox)
    setupCheckbox(checkbox: receiverBluetoothTxCheckBox)
    setupCheckbox(checkbox: receiverBluetoothRxCheckBox)
  }
  
  func setupCheckbox(checkbox: CheckBox) {
    checkbox.addTarget(self, action: #selector(onCheckBoxValueChange(_:)), for: .valueChanged)
  }
  
  @objc func onCheckBoxValueChange(_ sender: CheckBox) {
    print("checkbox: \(sender), isChecked: \(sender.isChecked)")
    updateEngSettings()
   }
  
  
  func updateEngSettings() {
    engSettings.beacon.sensorsEnabledDict[SensorType.proximity] = beaconProxCheckBox.isChecked
    engSettings.beacon.sensorsEnabledDict[SensorType.accelerometer] = beaconAccelCheckBox.isChecked
    engSettings.beacon.sensorsEnabledDict[SensorType.gyroscope] = beaconGyroCheckBox.isChecked
    engSettings.beacon.sensorsEnabledDict[SensorType.attitude] = beaconAttitudeCheckBox.isChecked
    engSettings.beacon.sensorsEnabledDict[SensorType.activity] = beaconActivityCheckBox.isChecked
    engSettings.beacon.sensorsEnabledDict[SensorType.heading] = beaconHeadingCheckBox.isChecked
    engSettings.beacon.sensorsEnabledDict[SensorType.pedometer] = beaconPedometerCheckBox.isChecked
    engSettings.beacon.sensorsEnabledDict[SensorType.altimeter] = beaconAltimeterCheckBox.isChecked
    engSettings.beacon.sensorsEnabledDict[SensorType.bluetoothTx] = beaconBluetoothTxCheckBox.isChecked
    engSettings.beacon.sensorsEnabledDict[SensorType.bluetoothRx] = beaconBluetoothRxCheckBox.isChecked
    
    engSettings.receiver.sensorsEnabledDict[SensorType.proximity] = receiverProxCheckBox.isChecked
    engSettings.receiver.sensorsEnabledDict[SensorType.accelerometer] = receiverAccelCheckBox.isChecked
    engSettings.receiver.sensorsEnabledDict[SensorType.gyroscope] = receiverGyroCheckBox.isChecked
    engSettings.receiver.sensorsEnabledDict[SensorType.attitude] = receiverAttitudeCheckBox.isChecked
    engSettings.receiver.sensorsEnabledDict[SensorType.activity] = receiverActivityCheckBox.isChecked
    engSettings.receiver.sensorsEnabledDict[SensorType.heading] = receiverHeadingCheckBox.isChecked
    engSettings.receiver.sensorsEnabledDict[SensorType.pedometer] = receiverPedometerCheckBox.isChecked
    engSettings.receiver.sensorsEnabledDict[SensorType.altimeter] = receiverAltimeterCheckBox.isChecked
    engSettings.receiver.sensorsEnabledDict[SensorType.bluetoothTx] = receiverBluetoothTxCheckBox.isChecked
    engSettings.receiver.sensorsEnabledDict[SensorType.bluetoothRx] = receiverBluetoothRxCheckBox.isChecked
  }

  
}



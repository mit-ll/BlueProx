//
//  EngineeringSettings.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation


enum SensorType: String {
  case proximity = "Proximity"
  case accelerometer = "Accelerometer"
  case gyroscope = "Gyroscope"
  case attitude = "Attitude"
  case activity = "Activity"
  case heading = "Heading"
  case pedometer = "Pedometer"
  case altimeter = "Altimeter"
  case bluetoothTx = "BluetoothTx"
  case bluetoothRx = "BluetoothRx"
}

class RoleSettings {
  var beacon: EngineeringSettings
  var receiver: EngineeringSettings
  
  init() {
    self.beacon = EngineeringSettings(enabledGroup: SensorsEnabledGroup.bluetoothOnly)
    self.receiver = EngineeringSettings(enabledGroup: SensorsEnabledGroup.noProx)
  }
}

enum SensorsEnabledGroup {
  case all
  case noProx
  case bluetoothOnly
}

class EngineeringSettings {
  
  // MARK: Consts
  
  private let sensorsAllDict : [SensorType: Bool] = [
    SensorType.proximity: true,
    SensorType.accelerometer: true,
    SensorType.gyroscope: true,
    SensorType.attitude: true,
    SensorType.activity: true,
    SensorType.heading: true,
    SensorType.pedometer: true,
    SensorType.altimeter: true,
    SensorType.bluetoothTx: true,
    SensorType.bluetoothRx: true
  ]
  
  private let sensorsNoProxDict : [SensorType: Bool] = [
    SensorType.proximity: false,
    SensorType.accelerometer: true,
    SensorType.gyroscope: true,
    SensorType.attitude: true,
    SensorType.activity: true,
    SensorType.heading: true,
    SensorType.pedometer: true,
    SensorType.altimeter: true,
    SensorType.bluetoothTx: true,
    SensorType.bluetoothRx: true
  ]
  
  private let sensorsBluetoothOnlyDict = [
      SensorType.proximity: false,
      SensorType.accelerometer: false,
      SensorType.gyroscope: false,
      SensorType.attitude: false,
      SensorType.activity: false,
      SensorType.heading: false,
      SensorType.pedometer: false,
      SensorType.altimeter: false,
      SensorType.bluetoothTx: true,
      SensorType.bluetoothRx: true
    ]
  
  
  // MARK: Properties
  
  var sensorsEnabledDict: [SensorType: Bool] = [:]
  
  init(enabledGroup: SensorsEnabledGroup) {
    switch enabledGroup {
      
    case .all:
      sensorsEnabledDict = sensorsAllDict
      
    case .noProx:
      sensorsEnabledDict = sensorsNoProxDict
      
    case .bluetoothOnly:
      sensorsEnabledDict = sensorsBluetoothOnlyDict
      
    }
  }
  
}

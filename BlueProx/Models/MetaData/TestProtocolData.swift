//
//  TestProtocolData.swift
//  BluetoothProximity
//
//  Created by Stacy Zeder on 4/14/20.
//  Copyright © 2020 Michael Wentz. All rights reserved.
//

import Foundation

// >>> TBD - Waiting for agreement on JSON

struct DeviceInfo: Codable {
  var codeVersion: String
  var phoneUuid: String
  var make: String
  var model: String
  var os: String
  var notes: String

  var dictionary: [String : Any] {
    return ["code_version": codeVersion,
            "phone_uuid": phoneUuid,
            "make": make,
            "model": model,
            "os": os,
            "notes": notes]
  }
  
  enum CodingKeys: String, CodingKey {
    case codeVersion = "code_version"
    case phoneUuid = "phone_uuid"
    case make = "make"
    case model = "model"
    case os = "os"
    case notes = "notes"
  }
  
  init(
   codeVersion: String,
   phoneUuid: String,
   make: String,
   model: String,
   os: String,
   notes: String) {
    self.codeVersion = codeVersion
    self.phoneUuid = phoneUuid
    self.make = make
    self.model = model
    self.os = os
    self.notes = notes
  }
  
  init() {
    self.codeVersion = ""
    self.phoneUuid = ""
    self.make = ""
    self.model = ""
    self.os = ""
    self.notes = ""
  }
  
  var description: String {
    var msg = "code version: " + codeVersion + "\n"
    msg = msg + "phone UUID: " + phoneUuid + "\n"
    msg = msg + "make: " + make + "\n"
    msg = msg + "model: " + model + "\n"
    msg = msg + "os: " + os + "\n"
    msg = msg + "notes: " + notes + "\n"
    return msg
  }
}

struct MetaData: Codable {
  let sessionId: String
  let beaconTester: DeviceInfo
  let appTester: DeviceInfo

  enum CodingKeys: String, CodingKey {
    case sessionId = "session_id"
    case beaconTester = "beacon_Tester"
    case appTester = "app_tester"
  }
  
  init(
   sessionId: String,
   beaconTester: DeviceInfo,
   appTester: DeviceInfo) {
    self.sessionId = sessionId
    self.beaconTester = beaconTester
    self.appTester = appTester
  }
  
  init() {
    self.sessionId = ""
    self.beaconTester = DeviceInfo()
    self.appTester = DeviceInfo()
  }
}

struct MetaDataTagged: Codable {
  var metaData: MetaData
  
  var dictionary: [String : Any] {
    return ["meta_data": metaData]
  }
  
  enum CodingKeys: String, CodingKey {
    case metaData = "meta_data"
  }
}

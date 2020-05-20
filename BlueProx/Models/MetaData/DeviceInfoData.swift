//
//  DeviceInfoData.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation


enum PhoneMake: String, CaseIterable {
  case none = ""
  case iPhone = "iPhone"
  case android = "Android"
}

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
  
  var loggerDescription: String {
    let msg = "\(make),\(model)"
    return msg
  }
  
}

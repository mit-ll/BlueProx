//
//  AllData.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

let schemaVerDefault: String = "3"
let schemaNameDefault: String = "MIT-Proximity-Upload"

struct AllData: Codable {
  var schemaVer: String
  var schemaName: String
  var appData: AppData
  var sessionData: [SessionData]
  
  enum CodingKeys: String, CodingKey {
    case schemaVer = "schema_ver"
    case schemaName = "schema_name"
    case appData = "app_data"
    case sessionData = "session_data"
  }
  
  init() {
    self.schemaVer = schemaVerDefault
    self.schemaName = schemaNameDefault
    self.appData = AppData()
    self.sessionData = []
  }
  
  init(
    appData: AppData,
    sessionData: [SessionData]
    // sensorData: AllSensorData
  ) {
    self.schemaVer = schemaVerDefault
    self.schemaName = schemaNameDefault
    self.appData = appData
    self.sessionData = sessionData
  }
  
  init(
    schemaVer: String,
    schemaName: String,
    appData: AppData,
    sessionData: [SessionData]
  ) {
    self.schemaVer = schemaVer
    self.schemaName = schemaName
    self.appData = appData
    self.sessionData = sessionData
  }

}


//
//  SessionData.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation


struct SessionData: Codable {
  var sessionID: String
  var setupNum: Int
  var setupLast: Bool
  var setupStartTime: String
  var setupEndTime: String
  var testTypeName: String     // NOTE: Taken from TestType.rawValue
  var testScenarioName: String // NOTE: Taken from ScenarioModel.name
  var participants: Participants
  var sensorData: AllSensorData

  enum CodingKeys: String, CodingKey {
    case sessionID = "session_id"
    case setupNum = "setup_num"
    case setupLast = "setup_last"
    case setupStartTime = "setup_start_time"
    case setupEndTime = "setup_end_time"
    case testTypeName = "test_type"
    case testScenarioName = "test_scenario"
    case participants = "participants"
    case sensorData = "sensor_data"
  }
  
  init() {
    self.sessionID = ""
    self.setupNum = 0
    self.setupLast = false
    self.setupStartTime = ""
    self.setupEndTime = ""
    self.testTypeName = ""
    self.testScenarioName = "Free Form"
    self.participants = Participants()
    self.sensorData = AllSensorData()
  }
  
  init(
    sessionID: String,
    setupNum: Int,
    setupLast: Bool,
    setupStartTime: String,
    setupEndTime: String,
    testTypeName: String,
    testScenarioName: String,
    participants: Participants,
    sensorData: AllSensorData) {
    self.sessionID = sessionID
    self.setupNum = setupNum
    self.setupLast = setupLast
    self.setupStartTime = setupStartTime
    self.setupEndTime = setupEndTime
    self.testTypeName = testTypeName
    self.testScenarioName = testScenarioName
    self.participants = participants
    self.sensorData = sensorData
  }
  
  var loggerDescription: String {
    var msg = "session_id," + sessionID + "\n"
    msg = msg + Utility.getTimestamp() + "," + "setup_num, " + setupNum.description + "\n"
    msg = msg + Utility.getTimestamp() + "," + "test_type, " + testTypeName + "\n"
    msg = msg + Utility.getTimestamp() + "," + "test_scenario, " + testScenarioName + "\n"
    
    return msg
  }
  
}

struct SessionDataTagged: Codable {
  var sessionData: SessionData
  
  var dictionary: [String : Any] {
    return ["session_data": sessionData]
  }
  
  enum CodingKeys: String, CodingKey {
    case sessionData = "session_data"
  }
}

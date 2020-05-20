//
//  clientServerFormatter.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation
import UIKit


class ClientServerFormatter {
  
  private var metaData: MetaData = MetaData()
  private var partnerScenario: ScenarioModel = ScenarioModel()  // NOTE: Maps to beaconSubjectInfo
  private var selfScenario: ScenarioModel = ScenarioModel()  // NOTE: Maps to scenarioSelected
  
  private var loopList: [(partnerLoc: Int, selfLoc: Int, subjAngle: Int)] = []
  private var loopStartTime: String = ""
  
  
  // MARK: Init /  Deinit
  
  init(
    metaData: MetaData,
    partnerScenario: ScenarioModel,
    selfScenario: ScenarioModel,
    loopList: [(partnerLoc: Int, selfLoc: Int, subjAngle: Int)],
    loopStartTime: String
  ) {
    self.metaData = metaData
    self.partnerScenario = partnerScenario
    self.selfScenario = selfScenario
    self.loopList = loopList
    self.loopStartTime = loopStartTime
  }
  
  
  // MARK: Methods
  
  func generateJsonDataDict(allData: AllData) -> ([String : Any]?, Any?) {
    do {
      // Encode object
      let jsonData = try JSONEncoder().encode(allData)
      print(String(data: jsonData, encoding: .utf8)!)

      // Convert to dictionary as exected by AlamoFire
      let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
      guard let dataDict = json as? [String : Any] else {
        return (nil, nil)
      }

      return (dataDict, json)
    } catch {
      print ("[STVC | postData] Serialization error: \(error)")
      return (nil, nil)
    }
  }
  
  // Generate all data, map from previous data structures to
  // updated schema
  func generateAllData(allLoopData: [SessionData]) -> AllData? {
    let appData = AppData()
    
    // If no data,then cannot generate packet
    if allLoopData.count == 0 {
      return nil
    }
    
    let allData = AllData(
      appData: appData,
      sessionData: allLoopData)
    
    return allData
  }
  
  func generateSessionData(
    sessionID: String,
    loopNum: Int,
    endTime: String,
    activateSensors: ActivateSensors,
    testType: TestType) -> SessionData? {
    
    let totalNumLoops = loopList.count
    
    // Self make, model
    let make = UIDevice.modelName
    let model = UIDevice.current.name
    let partnerEnv = partnerScenario.environmentType.rawValue + ", " + partnerScenario.environmentDetail.rawValue
    let selfEnv = selfScenario.environmentType.rawValue + ", " + selfScenario.environmentDetail.rawValue
    
    var partnerAngle = 0
    if testType == .situational {
      partnerAngle = -999
    }
    let partnerRole = testType == TestType.structured ? "Beacon" : "Partner"
    let selfRole = testType == TestType.structured ? "Receiver" : "Self"
    let partnerTester = Participant(
      userID: metaData.userId,
      distFt: loopList[loopNum].partnerLoc,
      relativeAngle: partnerAngle,
      deviceModel: metaData.partnerTester.model,
      environment: partnerEnv,
      onBodyLocation: partnerScenario.onBodyLocation.rawValue,
      subjectPose: partnerScenario.subjectPose.rawValue,
      role: partnerRole)

    let selfTester = Participant(
      userID: metaData.selfUserId,
      distFt: loopList[loopNum].selfLoc,
      relativeAngle: loopList[loopNum].subjAngle,
      deviceModel: make + ", " + model,
      environment: selfEnv,
      onBodyLocation: selfScenario.onBodyLocation.rawValue,
      subjectPose: selfScenario.subjectPose.rawValue,
      role: selfRole)
    
    let allSensorData = AllSensorData(
      accel: activateSensors.sensors.accelData.accel,
      activity: activateSensors.sensors.activityData.activity,
      altitude: activateSensors.sensors.altitudeData.altitude,
      bluetooth: activateSensors.scanner.bluetoothData.bluetooth,
      gravity: activateSensors.sensors.gravityData.gravity,
      gyro: activateSensors.sensors.gyroData.gyro,
      heading: activateSensors.sensors.headingData.heading,
      magField: activateSensors.sensors.magFieldData.magField,
      orientation: activateSensors.sensors.orientationData.orientation,
      pedometer: activateSensors.sensors.pedometerData.step,
      prox: activateSensors.sensors.proxData.prox
    )
    
    // Zero indexed values
    var isLastLoop = loopNum == (totalNumLoops - 1) ? true : false
    if testType == TestType.free_form {
      isLastLoop = true
    }
    let sessionData = SessionData(
      sessionID: sessionID,
      setupNum: loopNum,
      setupLast: isLastLoop,
      setupStartTime: loopStartTime,
      setupEndTime: endTime,
      testTypeName: selfScenario.type.rawValue,
      testScenarioName: selfScenario.name,
      participants: Participants(
        partnerTester: partnerTester,
        selfTester: selfTester),
      sensorData: allSensorData)
    
    return sessionData
  }

}

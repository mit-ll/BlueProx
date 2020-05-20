//
//  Participants.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation


struct Participants: Codable {
  let partnerTester: Participant
  let selfTester: Participant

  enum CodingKeys: String, CodingKey {
    case partnerTester = "partner"
    case selfTester = "self"
  }
  
  init(
   partnerTester: Participant,
   selfTester: Participant) {
    self.partnerTester = partnerTester
    self.selfTester = selfTester
  }
  
  init() {
    self.partnerTester = Participant()
    self.selfTester = Participant()
  }
  
  var loggerDescription: String {
    var msg = Utility.getTimestamp() + "," + "partner_tester, " + partnerTester.loggerDescription + "\n"
    msg = msg + Utility.getTimestamp() + "," + "self_tester, " + selfTester.loggerDescription
    return msg
  }
  
}

// -----------------------------

struct Participant: Codable {
  let userID: String
  let distFt: Int
  let relativeAngle: Int
  let deviceModel: String
  let environment: String
  let onBodyLocation: String
  let subjectPose: String
  let role: String

  enum CodingKeys: String, CodingKey {
    case userID = "id"
    case distFt = "dist_ft"
    case relativeAngle = "relative_angle"
    case deviceModel = "device_model"
    case environment = "environment"
    case onBodyLocation = "on_body_location"
    case subjectPose = "pose"
    case role = "role"
  }
  
  init() {
    self.userID = ""
    self.distFt = 0
    self.relativeAngle = 0
    self.deviceModel = ""
    self.environment = ""
    self.onBodyLocation = ""
    self.subjectPose = ""
    self.role = ""
  }
  
  init(
   userID: String,
   distFt: Int,
   relativeAngle: Int,
   deviceModel: String,
   environment: String,
   onBodyLocation: String,
   subjectPose: String,
   role: String
  ) {
    self.userID = userID
    self.distFt = distFt
    self.relativeAngle = relativeAngle
    self.deviceModel = deviceModel
    self.environment = environment
    self.onBodyLocation =  onBodyLocation
    self.subjectPose =  subjectPose
    self.role = role
  }
  
  var description: String {
    var msg = userID + ","
    msg = msg + distFt.description + ","
    msg = msg + relativeAngle.description + ","
    msg = msg + deviceModel + ","
    msg = msg + environment + ","
    msg = msg + onBodyLocation + ","
    msg = msg + subjectPose + ","
    msg = msg + role

    return msg
  }
  
  
  var loggerDescription: String {
    var msg = Utility.getTimestamp() + "," + "id, " + userID + "\n"
    msg = msg + Utility.getTimestamp() + "," + "dist_ft, " + distFt.description + "\n"
    msg = msg + Utility.getTimestamp() + "," + "relative_angle, " + relativeAngle.description + "\n"
    msg = msg + Utility.getTimestamp() + "," + "device_model, " + deviceModel + "\n"
    msg = msg + Utility.getTimestamp() + "," + "environment, " + environment + "\n"
    msg = msg + Utility.getTimestamp() + "," + "on_body_location, " + onBodyLocation + "\n"
    msg = msg + Utility.getTimestamp() + "," + "pose, " + subjectPose + "\n"
    msg = msg + Utility.getTimestamp() + "," + "role, " + role
    return msg
  }
  
}



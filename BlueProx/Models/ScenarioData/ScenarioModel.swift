//
//  ScenarioModel.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation


struct Environment: Codable, CustomStringConvertible {
  var envType: EnvironmentType
  var envDetail: EnvironmentDetail

  enum CodingKeys: String, CodingKey {
    case envType = "environment_type"
    case envDetail = "environment_detail"
  }

  init() {
    self.envType = EnvironmentType.unknown
    self.envDetail = EnvironmentDetail.unknown
  }

  init(env: Environment) {
    self.envType = env.envType
    self.envDetail = env.envDetail
  }

  init(envType: EnvironmentType = EnvironmentType.unknown,
       envDetail: EnvironmentDetail = EnvironmentDetail.unknown) {
    self.envType = envType
    self.envDetail = envDetail
  }

  var description: String {
    var msg = "env type: " + envType.rawValue + "\n"
    msg = msg + "env detail: " + envDetail.rawValue
    return msg
  }

  var shortDescription: String {
    let msg = envType.rawValue + ", " + envDetail.rawValue
    return msg
  }

}

enum EnvironmentType: String, Codable, CaseIterable {
  case unknown = ""
  case smallRoom = "small room"
  case mediumRoom = "medium room"
  case largeRoom = "large room"
  case hallway = "hallway"
  case outside = "outside"
}

enum EnvironmentDetail: String, Codable, CaseIterable {
  case unknown = ""
  case centerOpenRoom = "center open"
  case centerCongestedRoom = "center congested"
  case nearWallOpenRoom = "near wall open"
  case nearWallCongestedRoom = "near wall congested"
}

enum OnBodyLocation: String, Codable, CaseIterable {
  case unknown = ""
  case shirtPocket = "shirt pocket"
  case frontPantsPocket = "front pants pocket"
  case rearPantsPocket = "rear pants pocket"
  case inPurse = "in purse"
  case inHandLookingAtPhone = "in hand"
}

enum SubjectPose: String, Codable, CaseIterable {
  case unknown = ""
  case sitting = "sitting"
  case standing = "standing"
  case walking = "walking"
}

enum SubjectAngle: Int, Codable, CaseIterable {
  case facingForward = 0
  case facingSlightRight = 45
  case forwardSlightRight = 315 //-45
  case facingRight = 90
  case facingLeft = 270 // -90
  case facingBackward = 180
  case backwardSlightLeft = 135
  case backwardSlightRight = 225 // -135
  
  var description: String {
    switch self {
    case .facingForward: return "facing forward (0 deg)"
    case .facingSlightRight: return "forward slight right (45 deg)"
    case .forwardSlightRight: return "forward slight left (315 deg)"
    case .facingRight: return "facing right (90 deg)"
    case .facingLeft: return "facing left (270 deg)"
    case .facingBackward: return "facing backward (180 deg)"
    case .backwardSlightLeft: return "backward slight left (135 deg)"
    case .backwardSlightRight: return "backward slight right (225 deg)"
    }
  }
}

enum TestType: String, Codable, CaseIterable {
  case none = "- choose one -"
  case structured = "Structured"
  case situational = "Situational"
  case free_form = "Free Form"  // NOTE: Can be used for Robotic testing
}

struct ScenarioModel: Codable, CustomStringConvertible {
  var name: String
  var type: TestType
  var summary: String?
  var testDurationMinutes: Int
  var loopDurationSeconds: Int
  var environmentType: EnvironmentType
  var environmentDetail: EnvironmentDetail
  var onBodyLocation: OnBodyLocation
  var subjectPose: SubjectPose
  var subjectActivity: Activity
  var partnerLocations: [Int]?
  var selfLocations: [Int]?
  var subjectAngles: [SubjectAngle]?
  
  enum CodingKeys: String, CodingKey {
    case name
    case type
    case summary
    case testDurationMinutes = "test_duration_minutes"
    case loopDurationSeconds = "loop_duration_seconds"
    case environmentType = "environment_type"
    case environmentDetail = "environment_detail"
    case onBodyLocation = "on_body_location"
    case subjectPose = "pose"
    case subjectActivity = "subject_activity"
    case partnerLocations = "partner_locations"
    case selfLocations = "self_locations"
    case subjectAngles = "subject_angles"
  }
  
  init(name: String = "",
       type: TestType = TestType.structured,
       summary: String? = nil,
       testDurationMinutes: Int = 0,
       loopDurationSeconds: Int = 0,
       environmentType: EnvironmentType = EnvironmentType.unknown,
       environmentDetail: EnvironmentDetail = EnvironmentDetail.unknown,
       onBodyLocation: OnBodyLocation = OnBodyLocation.unknown,
       subjectPose: SubjectPose = SubjectPose.unknown,
       subjectActivity: Activity = Activity.unknown,
       partnerLocations: [Int]? = nil,
       selfLocations: [Int]? = nil,
       subjectAngles: [SubjectAngle]? = nil ) {
    self.name = name
    self.type = type
    self.summary = summary
    self.environmentType = environmentType
    self.environmentDetail = environmentDetail
    self.testDurationMinutes = testDurationMinutes
    self.loopDurationSeconds = loopDurationSeconds
    self.onBodyLocation = onBodyLocation
    self.subjectPose = subjectPose
    self.subjectActivity = subjectActivity
    self.partnerLocations = partnerLocations
    self.selfLocations = selfLocations
    self.subjectAngles = subjectAngles
  }
  
  init(scenario: ScenarioModel) {
    self.name = scenario.name
    self.type = scenario.type
    self.summary = scenario.summary
    self.environmentType = scenario.environmentType
    self.environmentDetail = scenario.environmentDetail
    self.testDurationMinutes = scenario.testDurationMinutes
    self.loopDurationSeconds = scenario.loopDurationSeconds
    self.onBodyLocation = scenario.onBodyLocation
    self.subjectPose = scenario.subjectPose
    self.subjectActivity = scenario.subjectActivity
    self.partnerLocations = scenario.partnerLocations
    self.selfLocations = scenario.selfLocations
    self.subjectAngles = scenario.subjectAngles
  }
  
  var shortDescription: String {
    var msg = "name: " + name + "\n"
    msg = msg + "test type: " + type.rawValue + "\n"
    if let s = summary {
      msg = msg + "summary: " + s.description + "\n"
    } else {
      msg = msg + "summary: " + " - " + "\n"
    }
    
    return msg
  }
  
  var description: String {
    var msg = "name: " + name + "\n"
    msg = msg + "test type: " + type.rawValue + "\n"
    if let s = summary {
      msg = msg + "summary: " + s.description + "\n"
    } else {
      msg = msg + "summary: " + " - " + "\n"
    }
    
    msg = msg + "test duration [min]: " + testDurationMinutes.description + "\n"
    msg = msg + "loop duration [sec]: " + loopDurationSeconds.description + "\n"

    msg = msg + "environmentType: " + environmentType.rawValue + "\n"
    msg = msg + "environmentDetail: " + environmentDetail.rawValue + "\n"
    msg = msg + "on body location: " + onBodyLocation.rawValue + "\n"
    msg = msg + "subject pose: " + subjectPose.rawValue + "\n"
    msg = msg + "subject activity: " + subjectActivity.rawValue + "\n"

    if let pl = partnerLocations {
      msg = msg + "partner locations: " + pl.description + "\n"
    } else {
      msg = msg + "partner locations: " + " - " + "\n"
    }
    
    if let sl = selfLocations {
      msg = msg + "self locations: " + sl.description + "\n"
    } else {
      msg = msg + "self locations: " + " - " + "\n"
    }
    
    if let sa = subjectAngles {
      msg = msg + "subject angles: \n"
      for item in sa {
        msg = msg + "     " + item.description + ", \n"
      }
    } else {
      msg = msg + "subject angles: " + " - " + "\n"
    }
    
    return msg
  }
  
  var loggerDescription: String {
    var msg = "app_name,\(AppData().appName)\n"
    msg = msg + Utility.getTimestamp() + "," + "app_ver,\(AppData().appVer)\n"
    msg = msg + Utility.getTimestamp() + "," + "scenario,\(type)_\(name) \n"
    msg = msg + Utility.getTimestamp() + "," + "environment,\(environmentType.rawValue),\(environmentDetail.rawValue)\n"
    msg = msg + Utility.getTimestamp() + "," + "self_on_body_location,\(onBodyLocation.rawValue)\n"
    msg = msg + Utility.getTimestamp() + "," + "self_pose,\(subjectPose)\n"
    msg = msg + Utility.getTimestamp() + "," + "self_activity,\(subjectActivity)"
    return msg
  }
  
  var loggerBeaconSubjectDescription: String {
    var msg = "partner_on_body_location,\(onBodyLocation.rawValue)\n"
    msg = msg + Utility.getTimestamp() + "," + "partner_pose,\(subjectPose)"

    return msg
  }
  
}

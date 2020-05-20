//
//  AttitudeData.swift
//  BlueProx
//


import Foundation

struct OrientationData: Codable {
  let timestamp: String
  let pitch: Double
  let roll: Double
  let yaw: Double
  
  var dictionary: [String : Any] {
    return ["timetamp" : timestamp,
            "pitch": pitch,
            "roll": roll,
            "yaw": yaw]
  }
  
  enum CodingKeys: String, CodingKey {
    case timestamp
    case pitch
    case roll
    case yaw
  }
  
  var description: String {
    var msg = timestamp + ","
    msg = msg + pitch.description + ","
    msg = msg + roll.description + ","
    msg = msg + yaw.description + "\n"
    return msg
  }
}

struct OrientationDataAll: Codable {
    var orientation: [OrientationData]
    
    enum CodingKeys: String, CodingKey {
        case orientation = "orientation"
    }
}



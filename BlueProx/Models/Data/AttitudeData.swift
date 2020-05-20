//
//  AttitudeData.swift
//  BluetoothProximity
//
//  Created by TAIRAN WANG on 4/18/20.
//  Copyright © 2020 Michael Wentz. All rights reserved.
//

import Foundation

//struct AttitudeData: Codable {
//    let timestamp: String
//    let pitch: Double
//    let roll: Double
//    let yaw: Double
//    let gx: Double
//    let gy: Double
//    let gz: Double
//    let mfieldx: Double
//    let mfieldy: Double
//    let mfieldz: Double
//    let mfieldaccuracy: Int32
//
//    enum CodingKeys: String, CodingKey {
//        case timestamp
//        case pitch
//        case roll
//        case yaw
//        case gx
//        case gy
//        case gz
//        case mfieldx
//        case mfieldy
//        case mfieldz
//        case mfieldaccuracy
//    }
//
//    var description: String {
//        var msg = timestamp + ","
//        msg = msg + pitch.description + ","
//        msg = msg + roll.description + ","
//        msg = msg + yaw.description + ","
//        msg = msg + gx.description + ","
//        msg = msg + gy.description + ","
//        msg = msg + gz.description + ","
//        msg = msg + mfieldx.description + ","
//        msg = msg + mfieldy.description + ","
//        msg = msg + mfieldz.description + ","
//        msg = msg + mfieldaccuracy.description + "\n"
//        return msg
//    }
//}
//

struct AttitudeData: Codable {
  let timestamp: String
  let orientation: AttitudeOrientationData
  let gravity: AttitudeGravityData
  let magField: AttitudeMagFieldData
  
  var dictionary: [String : Any] {
    return ["time_stamp": timestamp,
            "orientation": orientation,
            "gravity": gravity,
            "magField": magField]
  }
  
  enum CodingKeys: String, CodingKey {
    case timestamp
    case orientation
    case gravity
    case magField
  }
  
  var description: String {
    var msg = timestamp + ","
    msg = msg + orientation.description + ","
    msg = msg + gravity.description + ","
    msg = msg + magField.description + "\n"
    return msg
  }
}


struct AttitudeDataAll: Codable {
  var attitude: [AttitudeData]
  
  enum CodingKeys: String, CodingKey {
    case attitude = "attitude"
  }
}

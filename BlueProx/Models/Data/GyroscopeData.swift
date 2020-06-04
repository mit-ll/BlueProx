//
//  GyroscopeData.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation

// Gyroscope rotation rate coordinates
struct GyroscopeData: Codable {
  let timestamp: String
  let x: Double
  let y: Double
  let z: Double
  
  var dictionary: [String : Any] {
    return ["timestamp": timestamp,
            "x": x,
            "y": y,
            "z": z]
  }
  
  enum CodingKeys: String, CodingKey {
    case timestamp = "timestamp"
    case x = "x"
    case y = "y"
    case z = "z"
  }
  
  var description: String {
    var msg = timestamp + ","
    msg = msg + x.description + ","
    msg = msg + y.description + ","
    msg = msg + z.description + "\n"
    return msg
  }
}

struct GyroscopeDataAll: Codable {
  var gyro: [GyroscopeData]
  
  var dictionary: [String : Any] {
    return ["gyro": gyro]
  }
  
  enum CodingKeys: String, CodingKey {
    case gyro = "gyro"
  }
}

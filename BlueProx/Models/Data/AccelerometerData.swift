//
//  AccelerometerData.swift
//  BlueProx
//

import Foundation


struct AccelerometerData: Codable {
  let timestamp: String
  let x: Double
  let y: Double
  let z: Double
  
  var dictionary: [String : Any] {
    return ["x": x,
            "y": y,
            "z": z]
  }
  
  enum CodingKeys: String, CodingKey {
    case timestamp
    case x
    case y
    case z
  }
  
  var description: String {
    var msg = timestamp + ","
    msg = msg + x.description + ","
    msg = msg + y.description + ","
    msg = msg + z.description + "\n"
    return msg
  }
}

struct AccelerometerDataAll: Codable {
  var accel: [AccelerometerData]
  
  enum CodingKeys: String, CodingKey {
    case accel = "accel_raw"
  }
}

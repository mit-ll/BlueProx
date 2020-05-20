//
//  GravityDat.swift
//  BlueProx
//


import Foundation

struct GravityData: Codable {
  let timestamp: String
  let gx: Double
  let gy: Double
  let gz: Double
  
  var dictionary: [String : Any] {
    return ["x": gx,
            "y": gy,
            "z": gz]
  }
  
  enum CodingKeys: String, CodingKey {
    case timestamp
    case gx = "x"
    case gy = "y"
    case gz = "z"
  }
  
  var description: String {
    var msg = timestamp + ","
    msg = msg + gx.description + ","
    msg = msg + gy.description + ","
    msg = msg + gz.description + "\n"
    return msg
  }
}


struct GravityDataAll: Codable {
  var gravity: [GravityData]
  
  enum CodingKeys: String, CodingKey {
    case gravity = "accel_gravity"
  }
}

//
//  MagFieldData.swift
//  BlueProx
//

import Foundation

struct MagFieldData: Codable {
  let timestamp: String
  let mfieldx: Double
  let mfieldy: Double
  let mfieldz: Double
  let mfieldaccuracy: Int32
  
  var dictionary: [String : Any] {
    return ["timestamp": timestamp,
            "x": mfieldx,
            "y": mfieldy,
            "z": mfieldx,
            "accuracy": mfieldaccuracy]
  }
  
  enum CodingKeys: String, CodingKey {
    case timestamp
    case mfieldx = "x"
    case mfieldy = "y"
    case mfieldz = "z"
    case mfieldaccuracy = "accuracy"
  }
  
  var description: String {
    var msg = timestamp + ","
    msg = msg + mfieldx.description + ","
    msg = msg + mfieldy.description + ","
    msg = msg + mfieldz.description + ","
    msg = msg + mfieldaccuracy.description + "\n"
    return msg
  }
}

struct MagFieldDataAll: Codable {
  var magField: [MagFieldData]
  
  enum CodingKeys: String, CodingKey {
    case magField = "magnetic_field"
  }
}

